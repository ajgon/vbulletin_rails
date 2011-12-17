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
    # VBulletin tables prefix in database. It must set same as <tt>$config['Database']['tableprefix']</tt> in your VBulletin forum:
    PREFIX = get_vbulletin_prefix

    establish_vbulletin_connection
  end
end
