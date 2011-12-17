module ActiveRecord

  # ActiveRecord::Base extension for vbulletin methods
  class Base

    # Method used in user processing model to include vbulletin support
    #
    #   class User < ActiveRecord::Base
    #     include_vbulletin
    #   end
    #
    # With this method included, two hooks on User are added:
    # * When user is created - additional VBulletin account corresponding to user email and password is created, see: add_vbulletin
    # * When user is updated - corresponding VBulletin password is updated, see: update_vbulletin
    # * When user is validated - corresponding VBulletin object is validated as well, see: validate_vbulletin 
    def self.include_vbulletin
      before_validation :validate_vbulletin
      before_create :add_vbulletin
      after_update :update_vbulletin
    end
    
    # Method used in user processing model to overwrite default column names.
    # Normally VBulletinRails assumes, that User model contains columns with names 'email', 'password' and (optional) 'username'.
    # If you want to overwrite this, use this method as follows:
    #
    #   class User < ActiveRecord::Base
    #     set_column_names_for_vbulletin :email => :my_email_column_name, :password => :my_password_column_name, :username => :my_login_column_name
    #   end
    #
    def self.set_column_names_for_vbulletin options
      @@vbulletin_column_names = {:email => :email, :password => :password, :username => :username}.merge(options.symbolize_keys)
    end

    private
    # Filter launched <tt>before_create</tt>, it registers given user in VBulletin forum
    def add_vbulletin
      VBulletinRails::User.register(register_parameters_from_user_model)
    end

    # Filter launched <tt>after_update</tt>, updates VBulletin user password
    def update_vbulletin
      vb_user = VBulletinRails::User.find_by_email(self.email)
      vb_user.password = self.password
    end
    
    # Filter launched <tt>before_validation</tt>, won't allow using it model to validate unless VBulletin validates properly
    def validate_vbulletin
      vb_user = VBulletinRails::User.new(register_parameters_from_user_model)
      unless vb_user.valid?
        vb_user.errors.each do |error, message|
          self.errors.add('vbulletin_' + error.to_s, message)
        end
        return false
      end
    end
    
    # Returns hash of parameters ready to pass to VBulletinRails::User constructor
    def register_parameters_from_user_model
      register_parameters = [:email, :password, :username].collect do |vbulletin_column_name|
        [vbulletin_column_name, (self.respond_to?(@@vbulletin_column_names[vbulletin_column_name]) ? self.send(@@vbulletin_column_names[vbulletin_column_name]) : nil)]
      end
      Hash[*register_parameters.flatten]
    end
        
    # Get database configuration options
    def self.database_configuration
      begin
        Rails.configuration.database_configuration
      rescue NoMethodError
        YAML.load_file(File.exists?(File.join(Dir.pwd, 'config', 'database.yml')) ? File.join(Dir.pwd, 'config', 'database.yml') : File.join(Dir.pwd, 'test', 'dummy', 'config', 'database.yml'))
      end
    end

    # Get valid VBulettin database.yml section
    def self.db_env
      base_env = (defined?(Rails) ? Rails.env : 'test')
      database_configuration['vbulletin_' + base_env] ? 'vbulletin_' + base_env : base_env
    end
    
    # Establish connection to VBulletin database if differs from the main one
    def self.establish_vbulletin_connection
      establish_connection(database_configuration[db_env]) if db_env.match(/vbulletin_/)
    end
    
    # Returns proper prefix for VBulletin tables
    def self.get_vbulletin_prefix
      ((database_configuration[db_env] && database_configuration[db_env]['prefix']) ? database_configuration[db_env]['prefix'] : '')
    end
  end
end

#:nodoc: all
module ActionController #:nodoc:

  # ActionController::Base extension for vbulletin methods
  class Base

    before_filter :act_as_vbulletin

    private
    # Signs in VBulletin user, when correct email/username and password are provided
    # It also sets <tt>session[:vbulletin_userid]</tt> to <tt>VBulletinRails::User#userid</tt> which can be checked in your application if needed.
    #
    #   vbulletin_login :email => 'user@example.com', :password => 'user password' # signs in by user email
    #   vbulletin_login :username => 'username',      :password => 'user password' # signs in by username
    def vbulletin_login options = {}
      vb_user = nil
      vb_user = VBulletinRails::User.find_by_email(options[:email]) if options[:email]
      vb_user = VBulletinRails::User.find_by_username(options[:username]) if options[:username] and vb_user.blank?

      return false unless vb_user and vb_user.authenticate(options[:password])

      vb_session = VBulletinRails::Session.set(options.merge({:request => request, :user => vb_user}))
      session[:vbulletin_userid] = vb_user.userid
      cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      cookies[:bb_sessionhash] = vb_session.sessionhash

      set_permanent_vbulletin_session_for vb_user if options[:permanent]

      return vb_user
    end
    
    # Destroys VBulletin user session
    def vbulletin_logout
      VBulletinRails::Session.destroy(cookies[:bb_sessionhash])
      cookies.delete(:bb_lastactivity)
      cookies.delete(:bb_lastvisit)
      cookies.delete(:bb_sessionhash)
      cookies.delete(:bb_userid)
      cookies.delete(:bb_password)
      session.delete(:vbulletin_userid)
      session.delete(:vbulletin_permanent)
    end

    # It checks for VBulletin cookies and determines status of the user.
    # When user is logged in VBulletin, but not logged in application, this method takes care of it and signs user in as well.
    # Same for log out - if user logged out from VBulletin forum, any request to application will log him out.
    # By default this filter is turned on. To disable it, user skip_before_filter in desired controller or globally.
    #
    # Example
    #   class ApplicationController < ActionController::Base
    #     skip_before_filter :act_as_vbulletin
    #   end
    def act_as_vbulletin
      if (cookies[:bb_sessionhash] and (vb_session = VBulletinRails::Session.find_by_sessionhash(cookies[:bb_sessionhash])) and vb_session.userid > 0) or
        (cookies[:bb_userid].to_i > 0 and (vb_user = VBulletinRails::User.find_by_userid(cookies[:bb_userid])) and vb_user.authenticate_bb_password(cookies[:bb_password]))

        if cookies[:bb_userid].to_i > 0 and (vb_user = VBulletinRails::User.find_by_userid(cookies[:bb_userid])) and vb_user.authenticate_bb_password(cookies[:bb_password])
          vb_session = VBulletinRails::Session.set(:request => request, :user => vb_user)
          set_permanent_vbulletin_session_for vb_user
        end

        session[:vbulletin_userid] = vb_session.userid unless session[:vbulletin_userid]
        cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      else
        session.delete(:vbulletin_userid)
        session.delete(:vbulletin_permanent)
      end
    end

    # If your application uses "Remember me" variation, this method takes care for VBulletin and sets remember me cookie as well.
    # It takes VBulletinRails::User instance as parameter.
    # It also sets <tt>session[:vbulletin_permanent]</tt> to <tt>true</tt> which can be checked in your application if needed.
    #
    # To use it, a <tt>config.vbulletin.cookie_salt</tt> must be set. See: Rails::Application::Configuration vbulletin options
    #
    #   class SessionsController < ApplicationController
    #     def create
    #       vb_user = VBulletinRails::User.find_by_email('user@example.com')
    #       set_permanent_vbulletin_session_for vb_user
    #     end
    #   end
    def set_permanent_vbulletin_session_for vb_user
      cookies.permanent[:bb_userid] = vb_user.userid
      cookies.permanent[:bb_password] = vb_user.bb_password
      session[:vbulletin_permanent] = true
    end

    # Returns VBulletinRails::User object of currently logged in user. Analogic to standard, convenctional <tt>current_user</tt> method.
    def current_vbulletin_user
      VBulletinRails::User.find_by_userid(session[:vbulletin_userid])
    end

  end
end

#:nodoc: all
module Rails 
  class Application #:nodoc:

    # Add config.vbulletin.<parameter> accessor. Supported parameters are:
    # * <tt>config.vbulletin.cookie_salt = 'COOKIE_SALT'</tt> - required if you want to user "Remember me" functionality.
    #   It contains a VBulletin <tt>COOKIE_SALT</tt> special value, which is used when creating "Remember me" cookie.
    #   Cookie salt is located in <tt>includes/functions.php</tt> in line 34 of your VBulletin package and is unique for every application.
    class Configuration < ::Rails::Engine::Configuration
      # Adds config.vbulletin.<parameter> reader support
      def vbulletin
        @vbulletin ||= ActiveSupport::OrderedOptions.new
      end

      # Adds config.vbulletin.<parameter> writer support
      def vbulletin=(value)
        @vbulletin ||= ActiveSupport::OrderedOptions.new
        @vbulletin.value = value
        value
      end
    end
  end
end



module ActiveRecord
  class SchemaDumper #:nodoc:
    private_class_method :new

    def self.dump(connection=ActiveRecord::Base.connection, stream=STDOUT)
      old_stream = stream
      stream = StringIO.new
      new(connection).dump(stream)
      fixed_string = stream.string.gsub(/:limit => 0,?/, '            ')
      old_stream.rewind
      old_stream.puts fixed_string
      old_stream
    end

  end
end

ActiveRecord::SchemaDumper.ignore_tables += ['access', 'action', 'ad', 'adcriteria', 'adminhelp', 'administrator', 'adminlog', 'adminmessage', 'adminutil',
                                             'album', 'albumupdate', 'announcement', 'announcementread', 'apiclient', 'apilog', 'apipost', 'attachment',
                                             'attachmentcategory', 'attachmentcategoryuser', 'attachmentpermission', 'attachmenttype', 'attachmentviews', 'autosave',
                                             'avatar', 'bbcode', 'bbcode_video', 'block', 'blockconfig', 'blocktype', 'bookmarksite', 'cache', 'cacheevent',
                                             'calendar', 'calendarcustomfield', 'calendarmoderator', 'calendarpermission', 'contentpriority', 'contenttype', 'cpsession',
                                             'cron', 'cronlog', 'customavatar', 'customprofile', 'customprofilepic', 'datastore', 'dbquery', 'deletionlog',
                                             'discussion', 'discussionread', 'editlog', 'event', 'externalcache', 'faq', 'filedata', 'forum', 'forumpermission',
                                             'forumprefixset', 'forumread', 'groupmessage', 'groupmessage_hash', 'groupread', 'holiday', 'humanverify', 'hvanswer',
                                             'hvquestion', 'icon', 'imagecategory', 'imagecategorypermission', 'indexqueue', 'infraction', 'infractionban',
                                             'infractiongroup', 'infractionlevel', 'language', 'mailqueue', 'moderation', 'moderator', 'moderatorlog', 'notice',
                                             'noticecriteria', 'noticedismissed', 'package', 'passwordhistory', 'paymentapi', 'paymentinfo', 'paymenttransaction',
                                             'phrase', 'phrasetype', 'picturecomment', 'picturecomment_hash', 'picturelegacy', 'plugin', 'pm', 'pmreceipt', 'pmtext',
                                             'pmthrottle', 'podcast', 'podcastitem', 'poll', 'pollvote', 'post', 'postedithistory', 'posthash', 'postlog',
                                             'postparsed', 'prefix', 'prefixpermission', 'prefixset', 'product', 'productcode', 'productdependency',
                                             'profileblockprivacy', 'profilefield', 'profilefieldcategory', 'profilevisitor', 'ranks', 'reminder', 'reputation',
                                             'reputationlevel', 'route', 'rssfeed', 'rsslog', 'searchcore', 'searchcore_text', 'searchgroup', 'searchgroup_text',
                                             'searchlog', 'setting', 'settinggroup', 'sigparsed', 'sigpic', 'skimlinks', 'smilie', 'socialgroup',
                                             'socialgroupcategory', 'socialgroupicon', 'socialgroupmember', 'spamlog', 'stats', 'strikes', 'style', 'stylevar',
                                             'stylevardfn', 'subscribediscussion', 'subscribeevent', 'subscribeforum', 'subscribegroup', 'subscribethread', 'subscription',
                                             'subscriptionlog', 'subscriptionpermission', 'tachyforumcounter', 'tachyforumpost', 'tachythreadcounter', 'tachythreadpost',
                                             'tag', 'tagcontent', 'tagsearch', 'template', 'templatehistory', 'templatemerge', 'thread', 'threadrate', 'threadread',
                                             'threadredirect', 'threadviews', 'upgradelog', 'useractivation', 'userban', 'userchangelog', 'usercss', 'usercsscache',
                                             'usergroup', 'usergroupleader', 'usergrouprequest', 'userlist', 'usernote', 'userpromotion', 'usertitle', 'visitormessage',
                                             'visitormessage_hash'].collect {|table| ActiveRecord::Base.get_vbulletin_prefix + table}
