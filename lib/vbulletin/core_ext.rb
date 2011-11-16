module ActiveRecord
  class Base
    def self.include_vbulletin
      after_create :add_vbulletin
      after_update :update_vbulletin
    end

    private
    def add_vbulletin
      #TODO make it parametable
      VBulletin::User.register(:email => self.email, :password => self.password, :username => (self.respond_to?(:username) ? self.username : nil))
    end

    def update_vbulletin
      vb_user = VBulletin::User.find_by_email(self.email)
      vb_user.password = self.password
    end
  end
end

module ActionController
  class Base

    before_filter :act_as_vbulletin

    private
    def vbulletin_login options = {}
      vb_user = nil
      vb_user = VBulletin::User.find_by_email(options[:email]) if options[:email]
      vb_user = VBulletin::User.find_by_username(options[:username]) if options[:username] and vb_user.blank?

      return false unless vb_user and vb_user.authenticate(options[:password])

      vb_session = VBulletin::Session.set(options.merge({:request => request, :user => vb_user}))
      session[:vbulletin_userid] = vb_user.userid
      cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      cookies[:bb_sessionhash] = vb_session.sessionhash

      set_permanent_vbulletin_session_for vb_user if options[:permanent]

      return vb_user
    end

    def vbulletin_logout
      VBulletin::Session.destroy(cookies[:bb_sessionhash])
      cookies.delete(:bb_lastactivity)
      cookies.delete(:bb_lastvisit)
      cookies.delete(:bb_sessionhash)
      cookies.delete(:bb_userid)
      cookies.delete(:bb_password)
      session.delete(:vbulletin_userid)
      session.delete(:vbulletin_permanent)
    end

    def act_as_vbulletin
      if (cookies[:bb_sessionhash] and (vb_session = VBulletin::Session.find_by_sessionhash(cookies[:bb_sessionhash])) and vb_session.userid > 0) or
        (cookies[:bb_userid].to_i > 0 and (vb_user = VBulletin::User.find_by_userid(cookies[:bb_userid])) and vb_user.authenticate_bb_password(cookies[:bb_password]))

        if cookies[:bb_userid].to_i > 0 and (vb_user = VBulletin::User.find_by_userid(cookies[:bb_userid])) and vb_user.authenticate_bb_password(cookies[:bb_password])
          vb_session = VBulletin::Session.set(:request => request, :user => vb_user)
          set_permanent_vbulletin_session_for vb_user
        end

        session[:vbulletin_userid] = vb_session.userid unless session[:vbulletin_userid]
        cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      else
        session.delete(:vbulletin_userid)
        session.delete(:vbulletin_permanent)
      end
    end

    def set_permanent_vbulletin_session_for vb_user
      cookies.permanent[:bb_userid] = vb_user.userid
      cookies.permanent[:bb_password] = vb_user.bb_password
      session[:vbulletin_permanent] = true
    end

    def current_vbulletin_user
      VBulletin::User.find_by_userid(session[:vbulletin_userid])
    end

  end
end

module Rails
  class Application
    class Configuration < ::Rails::Engine::Configuration
      def vbulletin
        @vbulletin ||= ActiveSupport::OrderedOptions.new
      end

      def vbulletin=(value)
        @vbulletin ||= ActiveSupport::OrderedOptions.new
        @vbulletin.value = value
        value
      end
    end
  end
end

#Rails.configuration.vbulletin = ActiveSupport::OrderedOptions.new


# Fix enum parse bug by schema dumper
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
# --

ActiveRecord::SchemaDumper.ignore_tables += ['vb_access', 'vb_action', 'vb_ad', 'vb_adcriteria', 'vb_adminhelp', 'vb_administrator', 'vb_adminlog', 'vb_adminmessage', 'vb_adminutil',
                                             'vb_album', 'vb_albumupdate', 'vb_announcement', 'vb_announcementread', 'vb_apiclient', 'vb_apilog', 'vb_apipost', 'vb_attachment',
                                             'vb_attachmentcategory', 'vb_attachmentcategoryuser', 'vb_attachmentpermission', 'vb_attachmenttype', 'vb_attachmentviews', 'vb_autosave',
                                             'vb_avatar', 'vb_bbcode', 'vb_bbcode_video', 'vb_block', 'vb_blockconfig', 'vb_blocktype', 'vb_bookmarksite', 'vb_cache', 'vb_cacheevent',
                                             'vb_calendar', 'vb_calendarcustomfield', 'vb_calendarmoderator', 'vb_calendarpermission', 'vb_contentpriority', 'vb_contenttype', 'vb_cpsession',
                                             'vb_cron', 'vb_cronlog', 'vb_customavatar', 'vb_customprofile', 'vb_customprofilepic', 'vb_datastore', 'vb_dbquery', 'vb_deletionlog',
                                             'vb_discussion', 'vb_discussionread', 'vb_editlog', 'vb_event', 'vb_externalcache', 'vb_faq', 'vb_filedata', 'vb_forum', 'vb_forumpermission',
                                             'vb_forumprefixset', 'vb_forumread', 'vb_groupmessage', 'vb_groupmessage_hash', 'vb_groupread', 'vb_holiday', 'vb_humanverify', 'vb_hvanswer',
                                             'vb_hvquestion', 'vb_icon', 'vb_imagecategory', 'vb_imagecategorypermission', 'vb_indexqueue', 'vb_infraction', 'vb_infractionban',
                                             'vb_infractiongroup', 'vb_infractionlevel', 'vb_language', 'vb_mailqueue', 'vb_moderation', 'vb_moderator', 'vb_moderatorlog', 'vb_notice',
                                             'vb_noticecriteria', 'vb_noticedismissed', 'vb_package', 'vb_passwordhistory', 'vb_paymentapi', 'vb_paymentinfo', 'vb_paymenttransaction',
                                             'vb_phrase', 'vb_phrasetype', 'vb_picturecomment', 'vb_picturecomment_hash', 'vb_picturelegacy', 'vb_plugin', 'vb_pm', 'vb_pmreceipt', 'vb_pmtext',
                                             'vb_pmthrottle', 'vb_podcast', 'vb_podcastitem', 'vb_poll', 'vb_pollvote', 'vb_post', 'vb_postedithistory', 'vb_posthash', 'vb_postlog',
                                             'vb_postparsed', 'vb_prefix', 'vb_prefixpermission', 'vb_prefixset', 'vb_product', 'vb_productcode', 'vb_productdependency',
                                             'vb_profileblockprivacy', 'vb_profilefield', 'vb_profilefieldcategory', 'vb_profilevisitor', 'vb_ranks', 'vb_reminder', 'vb_reputation',
                                             'vb_reputationlevel', 'vb_route', 'vb_rssfeed', 'vb_rsslog', 'vb_searchcore', 'vb_searchcore_text', 'vb_searchgroup', 'vb_searchgroup_text',
                                             'vb_searchlog', 'vb_setting', 'vb_settinggroup', 'vb_sigparsed', 'vb_sigpic', 'vb_skimlinks', 'vb_smilie', 'vb_socialgroup',
                                             'vb_socialgroupcategory', 'vb_socialgroupicon', 'vb_socialgroupmember', 'vb_spamlog', 'vb_stats', 'vb_strikes', 'vb_style', 'vb_stylevar',
                                             'vb_stylevardfn', 'vb_subscribediscussion', 'vb_subscribeevent', 'vb_subscribeforum', 'vb_subscribegroup', 'vb_subscribethread', 'vb_subscription',
                                             'vb_subscriptionlog', 'vb_subscriptionpermission', 'vb_tachyforumcounter', 'vb_tachyforumpost', 'vb_tachythreadcounter', 'vb_tachythreadpost',
                                             'vb_tag', 'vb_tagcontent', 'vb_tagsearch', 'vb_template', 'vb_templatehistory', 'vb_templatemerge', 'vb_thread', 'vb_threadrate', 'vb_threadread',
                                             'vb_threadredirect', 'vb_threadviews', 'vb_upgradelog', 'vb_useractivation', 'vb_userban', 'vb_userchangelog', 'vb_usercss', 'vb_usercsscache',
                                             'vb_usergroup', 'vb_usergroupleader', 'vb_usergrouprequest', 'vb_userlist', 'vb_usernote', 'vb_userpromotion', 'vb_usertitle', 'vb_visitormessage',
                                             'vb_visitormessage_hash']
