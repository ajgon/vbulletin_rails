module VBulletin
  class Userfield < VBulletin::Base
    set_table_name(PREFIX + 'userfield')
    set_primary_key(:userid)

    belongs_to :user, :foreign_key => :userid
  end
end