$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'vbulletin_rails/core_ext'
require 'vbulletin_rails/models/user'
require 'vbulletin_rails/models/userfield'
require 'vbulletin_rails/models/usertextfield'
require 'vbulletin_rails/models/session'

# This gem adds full support of PHP VBulletin forum in Rails application
#
# Author::    Igor Rzegocki (mailto:igor.rzegocki@gmail.com)
# Copyright:: Copyright (c) 2011 Igor Rzegocki
# License::   MIT License
module VBulletinRails

  class VBulletinRailsException < Exception #:nodoc:
  end

  # Validates if given string is a valid IP address
  def self.valid_ip? ip
    !!ip.to_s.match(/^\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b$/)
  end

  # Converts dotted IP address representation to its decimal value
  def self.ip2long ip
    return false unless valid_ip?(ip)
    ip.split('.').inject {|i,j| (i.to_i << 8) + j.to_i}.to_i
  end

  # This is a port of original <tt>fetch_alt_ip()</tt> function from VBulletin
  # It was extended to detect <tt>X-Real-IP</tt> header which is set by convenction in nginx proxy_pass directives
  #
  # From VBulletin:: <em>Fetches an alternate IP address of the current visitor, attempting to detect proxies etc.</em>
  # See:: vbulletin/includes/class_core.php:2992 <tt>fetch_alt_ip()</tt>
  def self.fetch_alt_ip headers
    alt_ip = headers['REMOTE_ADDR']
    alt_ip = headers['HTTP_X_REAL_IP'] if headers['HTTP_X_REAL_IP'] # proxy_pass nginx support for unicorn/passenger standalone instances

    if headers['HTTP_CLIENT_IP']
      alt_ip = headers['HTTP_CLIENT_IP']
    elsif headers['HTTP_X_FORWARDED_FOR'] and valid_ip?(headers['HTTP_X_FORWARDED_FOR'].split(',').first.strip)
      ranges = {
        '10.0.0.0/8' => [ip2long('10.0.0.0'), ip2long('10.255.255.255')],
        '127.0.0.0/8' => [ip2long('127.0.0.0'), ip2long('127.255.255.255')],
        '169.254.0.0/16' => [ip2long('169.254.0.0'), ip2long('169.254.255.255')],
        '172.16.0.0/12' => [ip2long('172.16.0.0'), ip2long('172.31.255.255')],
        '192.168.0.0/16' => [ip2long('192.168.0.0'), ip2long('192.168.255.255')]
      }
      ips = headers['HTTP_X_FORWARDED_FOR'].split(',')
      ips.each do |ip|
        ip = ip.strip
        next unless valid_ip?(ip) and (ip_long = ip2long(ip))
        private_ip = false
        ranges.values.each do |range|
          if ip_long >= range.first and ip_long <= range.last
            private_ip = true
            break
          end
        end

        unless private_ip
          alt_ip = ip
          break
        end
      end
    elsif headers['HTTP_FROM']
      alt_ip = headers['HTTP_FROM']
    end

    return alt_ip
  end

  # This is a port of original <tt>fetch_substr_ip()</tt> function from VBulletin
  #
  # From VBulletin:: <em>Returns the IP address with the specified number of octets removed</em>
  # See:: vbulletin/includes/class_core.php:3836 <tt>fetch_substr_ip()</tt>
  def self.fetch_substr_ip(ip, length = 1)
    length = length.to_i
    length = 1 if length < 0 or length > 3

    return ip.split('.')[0..(3 - length)].join('.')
  end

  # Generates hash of the current VBulletin session
  def self.idhash alt_ip, user_agent
    Digest::MD5.hexdigest(user_agent + fetch_substr_ip(alt_ip))
  end

  # Cleans everything in VBulletin tables. Used to setup tests.
  def self.clean_tables!
    VBulletinRails::User.delete_all
    VBulletinRails::Userfield.delete_all
    VBulletinRails::Usertextfield.delete_all
    VBulletinRails::Session.delete_all
  end

end
