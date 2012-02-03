module VBulletinRails
  class Usertextfield < ActiveRecord::Base #:nodoc:
    PREFIX = get_vbulletin_prefix
    establish_vbulletin_connection    

    self.table_name = (PREFIX + 'usertextfield')
    self.primary_key = (:userid)

    belongs_to :user, :foreign_key => :userid
  end
end
