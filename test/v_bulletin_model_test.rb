#require 'test_helper'
require 'active_record'
require 'vbulletin/models/v_bulletin'

class VBulletinTest < ActiveSupport::TestCase

  def setup
    @vbulletin = VBulletin.register(:email => 'vb1@example.com', :username => 'vb1', :password => 'password1')
  end
  
  def teardown
    @vbulletin.destroy
  end
  
  test "it should check vbulletin user authentication" do
    assert_instance_of VBulletin, @vbulletin.authenticate('password1')
    assert !@vbulletin.authenticate('wrongpassword')
  end

  
  test "it should check email validations" do

    #check email
    assert_raise VBulletinException do 
      vbulletin = VBulletin.register(:email => 'wrongemail', :password => 'password1')
    end
    
    #check format of email
    begin
      vbulletin = VBulletin.register(:email => 'wrongemail', :password => 'password1')
      assert false
    rescue VBulletinException => e
      assert_equal(('%s %s' % [:email.to_s.humanize, I18n.t(:invalid, :scope => 'activerecord.errors.messages')]), e.message)
    rescue
      assert false
    end
    
    #check uniqueness of email
    begin
      vbulletin = VBulletin.register(:email => 'vb1@example.com', :password => 'password2')
      assert false
    rescue VBulletinException => e
      assert_equal(('%s %s' % [:email.to_s.humanize, I18n.t(:taken, :scope => 'activerecord.errors.messages')]), e.message)
    rescue
      assert false
    end
  end
  
  test "it should create vbulletin object" do
    #should pass
    assert_instance_of VBulletin, @vbulletin
  end
  
end
