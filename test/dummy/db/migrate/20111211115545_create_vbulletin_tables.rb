class CreateVbulletinTables < ActiveRecord::Migration
  def self.up
    create_table "session", :primary_key => "sessionhash", :force => true do |t|
      t.integer "userid",                        :default => 0,  :null => false
      t.string  "host",           :limit => 15,  :default => "", :null => false
      t.string  "idhash",         :limit => 32,  :default => "", :null => false
      t.integer "lastactivity",                  :default => 0,  :null => false
      t.string  "location",                      :default => "", :null => false
      t.string  "useragent",      :limit => 100, :default => "", :null => false
      t.integer "styleid",        :limit => 2,   :default => 0,  :null => false
      t.integer "languageid",     :limit => 2,   :default => 0,  :null => false
      t.integer "loggedin",       :limit => 2,   :default => 0,  :null => false
      t.integer "inforum",        :limit => 2,   :default => 0,  :null => false
      t.integer "inthread",                      :default => 0,  :null => false
      t.integer "incalendar",     :limit => 2,   :default => 0,  :null => false
      t.integer "badlocation",    :limit => 2,   :default => 0,  :null => false
      t.integer "bypass",         :limit => 1,   :default => 0,  :null => false
      t.integer "profileupdate",  :limit => 2,   :default => 0,  :null => false
      t.integer "apiclientid",                   :default => 0,  :null => false
      t.string  "apiaccesstoken", :limit => 32,  :default => "", :null => false
      t.integer "isbot",          :limit => 1,   :default => 0,  :null => false
    end
  
    add_index "session", ["apiaccesstoken"], :name => "apiaccesstoken"
    add_index "session", ["idhash", "host", "userid"], :name => "guest_lookup"
    add_index "session", ["lastactivity"], :name => "last_activity"
    add_index "session", ["userid", "lastactivity"], :name => "user_activity"
  
    create_table "user", :primary_key => "userid", :force => true do |t|
      t.integer "usergroupid",         :limit => 2,   :default => 0,        :null => false
      t.string  "membergroupids",      :limit => 250, :default => "",       :null => false
      t.integer "displaygroupid",      :limit => 2,   :default => 0,        :null => false
      t.string  "username",            :limit => 100, :default => "",       :null => false
      t.string  "password",            :limit => 32,  :default => "",       :null => false
      t.date    "passworddate",                                             :null => false
      t.string  "email",               :limit => 100, :default => "",       :null => false
      t.integer "styleid",             :limit => 2,   :default => 0,        :null => false
      t.string  "parentemail",         :limit => 50,  :default => "",       :null => false
      t.string  "homepage",            :limit => 100, :default => "",       :null => false
      t.string  "icq",                 :limit => 20,  :default => "",       :null => false
      t.string  "aim",                 :limit => 20,  :default => "",       :null => false
      t.string  "yahoo",               :limit => 32,  :default => "",       :null => false
      t.string  "msn",                 :limit => 100, :default => "",       :null => false
      t.string  "skype",               :limit => 32,  :default => "",       :null => false
      t.integer "showvbcode",          :limit => 2,   :default => 0,        :null => false
      t.integer "showbirthday",        :limit => 2,   :default => 2,        :null => false
      t.string  "usertitle",           :limit => 250, :default => "",       :null => false
      t.integer "customtitle",         :limit => 2,   :default => 0,        :null => false
      t.integer "joindate",                           :default => 0,        :null => false
      t.integer "daysprune",           :limit => 2,   :default => 0,        :null => false
      t.integer "lastvisit",                          :default => 0,        :null => false
      t.integer "lastactivity",                       :default => 0,        :null => false
      t.integer "lastpost",                           :default => 0,        :null => false
      t.integer "lastpostid",                         :default => 0,        :null => false
      t.integer "posts",                              :default => 0,        :null => false
      t.integer "reputation",                         :default => 10,       :null => false
      t.integer "reputationlevelid",                  :default => 1,        :null => false
      t.string  "timezoneoffset",      :limit => 4,   :default => "",       :null => false
      t.integer "pmpopup",             :limit => 2,   :default => 0,        :null => false
      t.integer "avatarid",            :limit => 2,   :default => 0,        :null => false
      t.integer "avatarrevision",                     :default => 0,        :null => false
      t.integer "profilepicrevision",                 :default => 0,        :null => false
      t.integer "sigpicrevision",                     :default => 0,        :null => false
      t.integer "options",                            :default => 33570831, :null => false
      t.string  "birthday",            :limit => 10,  :default => "",       :null => false
      t.date    "birthday_search",                                          :null => false
      t.integer "maxposts",            :limit => 2,   :default => -1,       :null => false
      t.integer "startofweek",         :limit => 2,   :default => 1,        :null => false
      t.string  "ipaddress",           :limit => 15,  :default => "",       :null => false
      t.integer "referrerid",                         :default => 0,        :null => false
      t.integer "languageid",          :limit => 2,   :default => 0,        :null => false
      t.integer "emailstamp",                         :default => 0,        :null => false
      t.integer "threadedmode",        :limit => 2,   :default => 0,        :null => false
      t.integer "autosubscribe",       :limit => 2,   :default => -1,       :null => false
      t.integer "pmtotal",             :limit => 2,   :default => 0,        :null => false
      t.integer "pmunread",            :limit => 2,   :default => 0,        :null => false
      t.string  "salt",                :limit => 30,  :default => "",       :null => false
      t.integer "ipoints",                            :default => 0,        :null => false
      t.integer "infractions",                        :default => 0,        :null => false
      t.integer "warnings",                           :default => 0,        :null => false
      t.string  "infractiongroupids",                 :default => "",       :null => false
      t.integer "infractiongroupid",   :limit => 2,   :default => 0,        :null => false
      t.integer "adminoptions",                       :default => 0,        :null => false
      t.integer "profilevisits",                      :default => 0,        :null => false
      t.integer "friendcount",                        :default => 0,        :null => false
      t.integer "friendreqcount",                     :default => 0,        :null => false
      t.integer "vmunreadcount",                      :default => 0,        :null => false
      t.integer "vmmoderatedcount",                   :default => 0,        :null => false
      t.integer "socgroupinvitecount",                :default => 0,        :null => false
      t.integer "socgroupreqcount",                   :default => 0,        :null => false
      t.integer "pcunreadcount",                      :default => 0,        :null => false
      t.integer "pcmoderatedcount",                   :default => 0,        :null => false
      t.integer "gmmoderatedcount",                   :default => 0,        :null => false
      t.string  "assetposthash",       :limit => 32,  :default => "",       :null => false
      t.string  "fbuserid",                           :default => "",       :null => false
      t.integer "fbjoindate",                         :default => 0,        :null => false
      t.string  "fbname",                             :default => "",       :null => false
      t.string  "logintype",                          :default => "vb",     :null => false
      t.string  "fbaccesstoken",                      :default => "",       :null => false
    end
  
    add_index "user", ["birthday", "showbirthday"], :name => "birthday"
    add_index "user", ["birthday_search"], :name => "birthday_search"
    add_index "user", ["email"], :name => "email"
    add_index "user", ["fbuserid"], :name => "fbuserid"
    add_index "user", ["referrerid"], :name => "referrerid"
    add_index "user", ["usergroupid"], :name => "usergroupid"
    add_index "user", ["username"], :name => "username"
  
    create_table "userfield", :primary_key => "userid", :force => true do |t|
      t.text "temp",   :limit => 16777215
      t.text "field1", :limit => 16777215
      t.text "field2", :limit => 16777215
      t.text "field3", :limit => 16777215
      t.text "field4", :limit => 16777215
    end
  
    create_table "usertextfield", :primary_key => "userid", :force => true do |t|
      t.text "subfolders",  :limit => 16777215
      t.text "pmfolders",   :limit => 16777215
      t.text "buddylist",   :limit => 16777215
      t.text "ignorelist",  :limit => 16777215
      t.text "signature",   :limit => 16777215
      t.text "searchprefs", :limit => 16777215
      t.text "rank",        :limit => 16777215
    end
  end
  
  def self.down
    drop_table "session"
    drop_table "user"
    drop_table "userfield"
    drop_table "usertextfield"
  end
  
end
