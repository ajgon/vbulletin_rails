$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'vbulletin/core_ext'
require 'vbulletin/models/v_bulletin.rb'
require 'vbulletin/models/user.rb'
require 'vbulletin/models/userfield.rb'
require 'vbulletin/models/usertextfield.rb'

module VBulletin

  def self.valid_ip? ip
    !!ip.to_s.match(/^\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b$/)
  end

  def self.ip2long ip
    return false unless valid_ip?(ip)
    ip.split('.').inject {|i,j| (i.to_i << 8) + j.to_i}.to_i
  end

  def self.fetch_alt_ip headers
    alt_ip = headers['REMOTE_ADDR']

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

end
