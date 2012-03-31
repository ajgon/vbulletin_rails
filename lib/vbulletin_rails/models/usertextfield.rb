module VBulletinRails
  class Usertextfield < ActiveRecord::Base #:nodoc:
    PREFIX = get_vbulletin_prefix
    establish_vbulletin_connection

    if Rails.version >= '3.2'
      self.primary_key = :userid
      self.table_name = PREFIX + 'usertextfield'
    else
      set_primary_key(:userid)
      set_table_name(PREFIX + 'usertextfield')
    end

    belongs_to :user, :foreign_key => :userid
  end
end
