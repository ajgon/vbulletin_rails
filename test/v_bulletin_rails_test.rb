require 'test_helper'

class VBulletinRailsTest < ActiveSupport::TestCase #:nodoc:

  def setup
    @test_bad_ips = [nil, 'test', 132, '127', '125.234', '164.234.232', '149.156.123.1111', '1111.1111.1111.1111', '172.256.3.22', '256.256.256.256']
    @test_private_ips = {
      '192.168.0.1' => 3232235521,
      '127.0.0.1' => 2130706433,
      '169.254.32.239' => 2852004079,
      '172.24.55.27' => 2887268123,
      '10.25.145.1' => 169447681
    }
    @test_public_ips = {
      '212.77.100.101' => 3561841765,
      '213.180.146.27' => 3585380891,
      '89.248.171.136' => 1509469064,
      '8.8.8.8' => 134744072,
      '0.0.0.0' => 0,
      '255.255.255.255' => 4294967295,
      '255.255.255.0' => 4294967040,
      '255.255.0.0' => 4294901760,
      '255.0.0.0' => 4278190080
    }
  end

  test 'ip validator' do
    @test_bad_ips.each do |ip|
      assert !VBulletinRails::valid_ip?(ip), "Interpretes as valid IP: #{ip}"
    end
    (@test_private_ips.keys + @test_public_ips.keys).each do |ip|
      assert VBulletinRails::valid_ip?(ip), "Interpretes as invalid IP: #{ip}"
    end
  end

  test 'ip to long int converter' do
    @test_bad_ips.each do |ip|
      assert !VBulletinRails::ip2long(ip), "Interpretes as valid IP: #{ip}"
    end
    (@test_private_ips.keys + @test_public_ips.keys).each do |ip|
      assert VBulletinRails::ip2long(ip), "Interpretes as invalid IP: #{ip}"
    end
    @test_private_ips.merge(@test_public_ips).each_pair do |ip, longip|
      assert_equal longip, VBulletinRails::ip2long(ip), "Wrong value for IP: #{ip}"
    end
  end

  test 'alt_ip retriever' do
    headers = {'REMOTE_ADDR' => '199.99.99.99'}
    assert_equal headers['REMOTE_ADDR'], VBulletinRails::fetch_alt_ip(headers)
    
    headers['HTTP_X_REAL_IP'] = '199.99.99.9'
    assert_equal headers['HTTP_X_REAL_IP'], VBulletinRails::fetch_alt_ip(headers)

    headers['HTTP_CLIENT_IP'] = '188.88.88.88'
    assert_equal headers['HTTP_CLIENT_IP'], VBulletinRails::fetch_alt_ip(headers)
    headers.delete('HTTP_CLIENT_IP')

    headers['HTTP_X_FORWARDED_FOR'] = '277.77.77.77, 166.66.66.66'
    assert_equal headers['HTTP_X_REAL_IP'], VBulletinRails::fetch_alt_ip(headers)
    headers['HTTP_X_FORWARDED_FOR'] = @test_private_ips.keys.join(', ')
    assert_equal headers['HTTP_X_REAL_IP'], VBulletinRails::fetch_alt_ip(headers)
    headers['HTTP_X_FORWARDED_FOR'] += ', 155.55.55.55'
    assert_equal '155.55.55.55', VBulletinRails::fetch_alt_ip(headers)
    headers['HTTP_X_FORWARDED_FOR'] = '144.44.44.44'
    assert_equal '144.44.44.44', VBulletinRails::fetch_alt_ip(headers)
    headers.delete('HTTP_X_FORWARDED_FOR')

    headers['HTTP_FROM'] = '133.33.33.33'
    assert_equal '133.33.33.33', VBulletinRails::fetch_alt_ip(headers)

    headers['HTTP_CLIENT_IP'] = '122.22.22.22'
    headers['HTTP_X_FORWARDED_FOR'] = '111.111.111.111'
    ['HTTP_CLIENT_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_FROM', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'].each do |header|
      assert_equal headers[header], VBulletinRails::fetch_alt_ip(headers)
      headers.delete(header)
    end

  end

  test 'fetch_subtr_ip function test' do
    ip = '123.45.6.78'
    assert_equal '123.45.6.78', VBulletinRails::fetch_substr_ip(ip, 0)
    assert_equal '123.45.6.78', VBulletinRails::fetch_substr_ip(ip, 'test')
    assert_equal '123.45.6.78', VBulletinRails::fetch_substr_ip(ip, nil)
    assert_equal '123.45.6', VBulletinRails::fetch_substr_ip(ip)
    assert_equal '123.45.6', VBulletinRails::fetch_substr_ip(ip, 25)
    assert_equal '123.45.6', VBulletinRails::fetch_substr_ip(ip, 1)
    assert_equal '123.45.6', VBulletinRails::fetch_substr_ip(ip, -1)
    assert_equal '123.45', VBulletinRails::fetch_substr_ip(ip, 2)
    assert_equal '123', VBulletinRails::fetch_substr_ip(ip, 3)
  end

end
