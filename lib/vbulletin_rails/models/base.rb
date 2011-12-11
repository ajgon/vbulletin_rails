module VBulletinRails

  # Sets connection to VBulletin database. If <tt>vbulletin_<environemt></tt> specified in <tt>database.yml</tt> file, it connets to that database instead of normal database.
  #
  #   # database.yml
  #   # Sets VBulletin connetion to another database located in external.com, and assumes that all VBulletin tables have vb_ prefix.
  #   development:
  #     adapter: mysql2
  #     username: user
  #     password: pass
  #     host: localhost
  #   vbulletin_development:
  #     adapter: mysql2
  #     username: vb
  #     password: vbpass
  #     host: external.com
  #     prefix: vb_
  class Base < ActiveRecord::Base
    #--
    #TODO: It works, however - check if it's possible to launch plugin by bundler AFTER rails initialization
    #++
    # name of Vbulletin section in <tt>database.yml</tt> file depending on set environment
    DB_ENV = 'vbulletin_' + (defined?(Rails) ? Rails.env : 'test')
    # connection parameters to VBulletin database
    YAML_CONFIG = YAML.load_file(File.exists?(File.join(Dir.pwd, 'config', 'database.yml')) ? File.join(Dir.pwd, 'config', 'database.yml') : File.join(Dir.pwd, 'test', 'dummy', 'config', 'database.yml'))
    # VBulletin tables prefix in database. It must set same as <tt>$config['Database']['tableprefix']</tt> in your VBulletin forum:
    PREFIX = (( YAML_CONFIG[DB_ENV] &&
                YAML_CONFIG[DB_ENV]['prefix']) ?
                YAML_CONFIG[DB_ENV]['prefix'] :
                '')
    establish_connection(YAML_CONFIG[DB_ENV]) if YAML_CONFIG[DB_ENV]
  end
end
