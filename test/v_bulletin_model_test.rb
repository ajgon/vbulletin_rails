#require 'test_helper'
require 'active_record'
require 'vbulletin/models/v_bulletin'
require 'vbulletin/models/user'
require 'vbulletin/models/userfield'
require 'vbulletin/models/usertextfield'

class VBulletinTest < ActiveSupport::TestCase

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
  end
  
  test "it should contain additional tables" do
    assert_kind_of VBulletin::Userfield, @vbulletin.userfield
    assert_kind_of VBulletin::Usertextfield, @vbulletin.usertextfield
  end
  
end
