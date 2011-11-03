module VBulletin
  class Session < VBulletin::Base

    VB_SESSION_TIMEOUT = 900

    set_table_name(PREFIX + 'session')
    set_primary_key(:sessionhash)
    inheritance_column=('sdfsadfasdf')

    belongs_to :user, :foreign_key => :userid

    def update_timestamps
      unless user.blank?
        last_activity = user.lastactivity
        nowstamp = Time.now.to_i
        last_visit = (((nowstamp - last_activity) > VB_SESSION_TIMEOUT) ? last_activity : user.lastvisit)
        update_attributes(:lastactivity => nowstamp)
        user.update_attributes(:lastactivity => nowstamp, :lastvisit => last_visit)
        return [nowstamp, last_visit]
      end
      return [0, 0]
    end

    def self.set options = {}
      options = options.symbolize_keys
      request = check_request options

      user = nil
      user = User.find_by_email(options[:email]) if options[:email]
      user = User.find_by_username(options[:login]) if options[:login]
      raise VBulletinException, 'User not found' unless user

      nowstamp = Time.now.to_i
      alt_ip = VBulletin::fetch_alt_ip(request.headers)
      sessionhash = Digest::MD5.hexdigest((rand * Time.now.to_i * Time.now.usec).to_s)

      connection.execute("INSERT INTO `#{table_name}`
                          (`sessionhash`, `userid`, `host`, `idhash`, `lastactivity`, `location`, `useragent`)
                          VALUES
                          ('#{sessionhash}', '#{user.userid}', '#{alt_ip}', '#{VBulletin::idhash(alt_ip, request.user_agent)}',
                          '#{nowstamp}', 'application', '#{request.user_agent}')")

      return find_by_sessionhash(sessionhash)
    end

    def self.get options = {}
      options = options.symbolize_keys
      request = check_request options
      idhash = VBulletin::idhash(VBulletin::fetch_alt_ip(request.headers), request.user_agent)
      session = find_by_sessionhash(options[:sessionhash].to_s)

      if session
        return (session.idhash == idhash && (Time.now.to_i - session.lastactivity) < VB_SESSION_TIMEOUT) ? session : false;
      end
      return false
    end

    private
    def self.check_request options = {}
      request = options[:request]
      raise VBulletinException, 'Request is mandatory' unless request
      return request
    end

  end
end