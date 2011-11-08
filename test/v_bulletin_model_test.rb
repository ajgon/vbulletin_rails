require 'test_helper'
require 'active_record'
require 'active_resource/http_mock'
require 'vbulletin/models/base'
require 'vbulletin/models/user'
require 'vbulletin/models/userfield'
require 'vbulletin/models/usertextfield'
require 'vbulletin/models/session'

class VBulletinModelTest < ActiveSupport::TestCase

  def setup
    @vbulletin = VBulletin::User.register(:email => 'vb1@example.com', :username => 'vb1', :password => 'password1')
  end

  def teardown
    @vbulletin.destroy
  end

  test "it should check vbulletin user authentication" do
    assert_instance_of VBulletin::User, @vbulletin.authenticate('password1')
    assert !@vbulletin.authenticate('wrongpassword')
  end


  test "it should check email validations" do

    #check email
    user = VBulletin::User.register(:email => 'wrongemail', :password => 'password1')
    assert user.errors.keys.include?(:email)
    assert user.errors.messages[:email].include?(I18n.t(:invalid, :scope => 'activerecord.errors.messages'))

    user = VBulletin::User.new({:email => 'vb1@example.com', :password => 'pass'}) #uniqueness
    assert !user.save
    assert user.errors.keys.include?(:email)
    assert user.errors.messages[:email].include?(I18n.t(:taken, :scope => 'activerecord.errors.messages'))
  end

  test "it should create vbulletin object" do
    #should pass
    assert_instance_of VBulletin::User, @vbulletin
    assert_equal nil, @vbulletin.birthday_search
    assert @vbulletin.userid.to_i > 0
  end

  test "it should contain additional tables" do
    assert_kind_of VBulletin::Userfield, @vbulletin.userfield
    assert_kind_of VBulletin::Usertextfield, @vbulletin.usertextfield
  end

  test 'it should check session model' do
    begin
      VBulletin::Session.set()
    rescue Exception => e
      assert_instance_of VBulletin::VBulletinException, e
      assert_equal 'Request is mandatory', e.message
    end
    begin
      VBulletin::Session.get()
    rescue Exception => e
      assert_instance_of VBulletin::VBulletinException, e
      assert_equal 'Request is mandatory', e.message
    end

    request = ActiveResource::Request.new(:get, '/', nil, {'REMOTE_ADDR' => '127.0.0.1', 'HTTP_USER_AGENT' => 'MockRq User Agent'})
    request.class.send(:define_method, :user_agent) do
      return headers['HTTP_USER_AGENT'].to_s
    end

    begin
      VBulletin::Session.set(:request => request)
    rescue Exception => e
      assert_instance_of VBulletin::VBulletinException, e
      assert_equal 'User not found', e.message
    end
    begin
      VBulletin::Session.set(:request => request, :email => 'wrongemail', :username => 'wronglogin)(P#@"")')
    rescue Exception => e
      assert_instance_of VBulletin::VBulletinException, e
      assert_equal 'User not found', e.message
    end

    vb_session = VBulletin::Session.set(:request => request, :email => 'vb1@example.com')
    get_session = VBulletin::Session.get(:sessionhash => vb_session.sessionhash, :request => request)

    assert_instance_of VBulletin::Session, get_session

  end

end
