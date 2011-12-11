module VBulletinRails

  # Model containing VBulletin User information
  class User < VBulletinRails::Base

    set_primary_key(:userid)
    set_table_name(PREFIX + 'user')

    validates_presence_of :email, :password, :on => :create
    validates_uniqueness_of :email, :on => :create
    validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create

    has_one :userfield, :foreign_key => :userid, :dependent => :delete
    has_one :usertextfield, :foreign_key => :userid, :dependent => :delete
    has_many :session, :foreign_key => :userid, :dependent => :delete_all

    # Authenticate VBulletin user with provided password. Returns VBulletinRails::User object if success
    def authenticate(passwd)
      User.password_hash(passwd.to_s, salt) == password ? self : false
    end
    
    # Authenticate VBulletin user with provided session hash. Returns VBulletinRails::User object if success
    def authenticate_bb_password(bb_password_hash)
      bb_password_hash == bb_password ? self : false
    end

    # Returns correct VBulletin session hash for user
    def bb_password
      Digest::MD5.hexdigest(password + Rails.configuration.vbulletin.cookie_salt)
    end
    
    # Sets new VBulletinRails::User password
    def password= passwd
      new_salt = User.fresh_salt
      self.passworddate = Date.today.to_s
      self.salt = new_salt
      self.send(:write_attribute, :password, User.password_hash(passwd.to_s, new_salt))
    end
    
    # Registers VBulletin user with given username/email and password
    #
    #   VBulletinRails::User.register :username => 'username',      :password => 'user password'
    #   VBulletinRails::User.register :email => 'user@example.com', :password => 'user password'
    def self.register options
      options = options.symbolize_keys

      username = options[:username].blank? ? options[:email] : options[:username]
      nowstamp = Time.now.to_i

      vb_user = self.new({
        :usergroupid => 2,
        :username => username.to_s,
        :password => options[:password],
        :email => options[:email].to_s,
        :usertitle => 'Junior Member',
        :joindate => nowstamp,
        :daysprune => -1,
        :lastvisit => nowstamp,
        :lastactivity => nowstamp,
        :reputationlevelid => 5,
        :timezoneoffset => '0',
        :options => 45108311,
        :birthday_search => '1970-01-01',
        :startofweek => -1,
        :languageid => 1
      })
      vb_user.userfield = Userfield.new
      vb_user.usertextfield = Usertextfield.new
      if vb_user.save
        connection.execute("UPDATE `#{PREFIX}user` SET `birthday_search` = '0000-00-00' WHERE `#{PREFIX}user`.`userid` = '#{vb_user.userid}'")
        return find(vb_user.userid)
      else
        return vb_user
      end
    end
    
    private
    #:nodoc:
    def self.password_hash password, salt
      Digest::MD5.hexdigest(Digest::MD5.hexdigest(password) + salt)
    end

    #:nodoc:
    def self.fresh_salt length = 30
      (1..length).map {(rand(33) + 93).chr}.join
    end

  end
end