module ActiveRecord
  class Base
    def self.create_vbulletin(email = :email, password = :password, username = :login)
      after_create :add_vbulletin
    end

    private
    def add_vbulletin
      VBulletin::User.register(:email => self.send(email), :password => self.send(password), :username => (self.respond_to?(username) ? self.send(username) : nil))
    end
  end
end

module ActionController
  class Base

    after_filter :act_as_vbulletin

    private
    def vbulletin_login options = {}
      user = nil
      if options[:login]
        user = VBulletin::User.find_by_username(options[:login])
      elsif options[:email]
        user = VBulletin::User.find_by_email(options[:email])
      end

      return false unless user and user.authenticate(options[:password])

      vb_session = VBulletin::Session.set(options.merge({:request => request}))
      session[:vbulletin_userid] = vb_session.userid
      cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      cookies[:bb_sessionhash] = vb_session.sessionhash

      return user
    end

    def vbulletin_logout
      cookies.delete(:bb_lastactivity)
      cookies.delete(:bb_lastvisit)
      cookies.delete(:bb_sessionhash)
      session.delete(:vbulletin_userid)
    end

    def act_as_vbulletin
      if cookies[:bb_sessionhash] and (vb_session = VBulletin::Session.find_by_sessionhash(cookies[:bb_sessionhash])) and vb_session.userid > 0
        session[:vbulletin_userid] = vb_session.userid unless session[:vbulletin_userid]
        cookies[:bb_lastactivity], cookies[:bb_lastvisit] = vb_session.update_timestamps
      else
        session.delete(:vbulletin_userid)
      end
    end

    def current_vbulletin_user
      VBulletin::User.find_by_userid(session[:vbulletin_userid])
    end

  end
end