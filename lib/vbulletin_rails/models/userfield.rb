module VBulletinRails
  class Userfield < VBulletinRails::Base #:nodoc:
    set_table_name(PREFIX + 'userfield')
    set_primary_key(:userid)

    belongs_to :user, :foreign_key => :userid
  end
end