module VBulletin
  class Base < ActiveRecord::Base
    #TODO: It works, however - check if it's possible to launch plugin by bundler AFTER rails initialization
    DB_ENV = 'vbulletin_' + (defined?(Rails) ? Rails.env : 'test')
    YAML_CONFIG = YAML.load_file(File.exists?(File.join(Dir.pwd, 'config', 'database.yml')) ? File.join(Dir.pwd, 'config', 'database.yml') : File.join(Dir.pwd, 'test', 'dummy', 'config', 'database.yml'))
    PREFIX = (( YAML_CONFIG[DB_ENV] &&
                YAML_CONFIG[DB_ENV]['prefix']) ?
                YAML_CONFIG[DB_ENV]['prefix'] + '_' :
                '')
    establish_connection(YAML_CONFIG[DB_ENV])
    #TODO: -------------------------------------------------------------------------------------------------
  end
end