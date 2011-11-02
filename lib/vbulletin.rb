$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'vbulletin/core_ext'
require 'vbulletin/models/v_bulletin.rb'
require 'vbulletin/models/user.rb'
require 'vbulletin/models/userfield.rb'
require 'vbulletin/models/usertextfield.rb'

module Vbulletin
end
