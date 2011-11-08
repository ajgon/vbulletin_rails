gem 'actionpack', '>= 3.0'
require 'test_helper'
require 'action_dispatch/testing/test_request'
require 'vbulletin/core_ext'

class VBulletinControllerTest < ActiveSupport::TestCase

  def setup
    @vbulletin = VBulletin::User.register(:email => 'vb1@example.com', :username => 'vb1', :password => 'password1')
    @controller = ActionController::Base.new
    @controller.request = ActionDispatch::TestRequest.new
  end

  def teardown
    @vbulletin.destroy
  end

  test 'login action' do
    assert !@controller.send(:vbulletin_login)
    assert !@controller.send(:vbulletin_login, :email => 'invalidemail')
    assert !@controller.send(:vbulletin_login, :username => 'vb1')
    assert !@controller.send(:vbulletin_login, :email => 'vb1@example.com')
    assert !@controller.send(:vbulletin_login, :username => 'vb1', :password => 'wrongpassword')
    assert !@controller.send(:vbulletin_login, :email => 'vb1@example.com', :password => 'wrongpassword')
    assert_instance_of VBulletin::User, @controller.send(:vbulletin_login, :username => 'vb1', :password => 'password1')
    assert_instance_of VBulletin::User, (user = @controller.send(:vbulletin_login, :email => 'vb1@example.com', :password => 'password1'))
    assert_equal @controller.session[:vbulletin_userid], @vbulletin.userid
    assert_equal @controller.send(:cookies)[:bb_lastactivity], user.lastactivity
    assert_equal @controller.send(:cookies)[:bb_lastvisit], user.lastvisit
    assert_match /[0-9a-f]{32}/, @controller.send(:cookies)[:bb_sessionhash]
  end

  test 'logout action' do
    user = @controller.send(:vbulletin_login, :email => 'vb1@example.com', :password => 'password1')
    assert_equal @controller.session[:vbulletin_userid], @vbulletin.userid
    assert_equal @controller.send(:cookies)[:bb_lastactivity], user.lastactivity
    assert_equal @controller.send(:cookies)[:bb_lastvisit], user.lastvisit
    assert_match /[0-9a-f]{32}/, @controller.send(:cookies)[:bb_sessionhash]
    @controller.send(:vbulletin_logout)
    assert_nil @controller.session[:vbulletin_userid]
    assert_nil @controller.send(:cookies)[:bb_lastactivity]
    assert_nil @controller.send(:cookies)[:bb_lastvisit]
    assert_nil @controller.send(:cookies)[:bb_sessionhash]
  end

  test 'act as vbulletin' do
    user = @controller.send(:vbulletin_login, :email => 'vb1@example.com', :password => 'password1')

    # User logged in via VBulletin
    @controller.session.delete(:vbulletin_userid)
    assert_nil @controller.session[:vbulletin_userid]
    @controller.send(:act_as_vbulletin)
    assert_equal @controller.session[:vbulletin_userid], @vbulletin.userid

    # User logged out via VBulletin
    @controller.send(:cookies).delete(:bb_sessionhash)
    assert_nil @controller.send(:cookies)[:bb_sessionhash]
    assert_equal @controller.session[:vbulletin_userid], @vbulletin.userid
    @controller.send(:act_as_vbulletin)
    assert_nil @controller.session[:vbulletin_userid]
  end

  test 'current_vbulletin_user' do
    user = @controller.send(:vbulletin_login, :email => 'vb1@example.com', :password => 'password1')
    assert_equal user, @controller.send(:current_vbulletin_user)
  end
end
