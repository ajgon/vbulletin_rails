module VBulletin
  class Usertextfield < VBulletin::Base #:nodoc:
    set_table_name(PREFIX + 'usertextfield')
    set_primary_key(:userid)

    belongs_to :user, :foreign_key => :userid
  end
end