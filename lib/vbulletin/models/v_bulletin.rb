class VBulletinException < Exception
end

class VBulletin < ActiveRecord::Base

  #TODO: It works, however - check if it's possible to launch plugin by bundler AFTER rails initialization
  DB_ENV = 'vbulletin_' + Rails.env
  YAML_CONFIG = YAML.load_file(File.join(Dir.pwd, 'config', 'database.yml'))
  PREFIX = (( YAML_CONFIG[DB_ENV] && 
              YAML_CONFIG[DB_ENV]['prefix']) ?
              YAML_CONFIG[DB_ENV]['prefix'] + '_' :
              '')
  establish_connection(YAML_CONFIG[DB_ENV]) 
  set_primary_key(:userid)
  set_table_name(PREFIX + 'user')
                      
  def authenticate(passwd)
    VBulletin.password_hash(passwd, salt) == password ? self : false
  end
  
  def self.register options
    options = options.symbolize_keys
    [:email, :password].each do |option|
      raise VBulletinException.new('%s %s' % [option.to_s.humanize, I18n.t(:blank, :scope => 'activerecord.errors.messages')]) if options[option].blank?
    end
    
    raise VBulletinException.new('%s %s' % [:email.to_s.humanize, I18n.t(:taken, :scope => 'activerecord.errors.messages')]) if find_by_email(options[:email])
    raise VBulletinException.new('%s %s' % [:email.to_s.humanize, I18n.t(:invalid, :scope => 'activerecord.errors.messages')]) if not options[:email] =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    
    username = options[:username].blank? ? options[:email] : options[:username]
    nowstamp = Time.now.to_i
    new_salt = fresh_salt
    connection.execute("
      INSERT INTO `#{table_name}` VALUES (NULL,2,'',0,'#{options[:username]}',
      '#{password_hash(options[:password], new_salt)}','#{Date.today.to_s}','#{options[:email]}',0,'',
      '','','','','','',1,0,'Junior Member',0,#{nowstamp},-1,#{nowstamp},#{nowstamp},0,0,0,10,5,'0',
      0,0,0,0,0,45108311,'','0000-00-00',-1,-1,'',0,1,0,0,-1,0,0,'#{new_salt}',0,0,0,'',0,0,0,0,0,0,
      0,0,0,0,0,0,'','',0,'','vb','',0,1)")
    user_id = connection.execute('SELECT LAST_INSERT_ID()').first.first
    connection.execute("
      INSERT INTO `#{PREFIX}userfield` VALUES (#{user_id},NULL,'','','','')")
    connection.execute("
      INSERT INTO `#{PREFIX}usertextfield` VALUES (#{user_id},NULL,NULL,NULL,NULL,'',NULL,NULL)")
    find(user_id)
  end
  
  private
  def self.password_hash password, salt
    Digest::MD5.hexdigest(Digest::MD5.hexdigest(password) + salt)
  end
  
  def self.fresh_salt length = 30
    (1..length).map {(rand(33) + 93).chr}.join
  end
  
end
