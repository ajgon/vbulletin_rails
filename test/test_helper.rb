# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

VBulletin::Session.connection.execute("ALTER TABLE `#{VBulletin::Session.table_name}` CHANGE `sessionhash` `sessionhash` char(32) NOT NULL DEFAULT ''") # Hack for Rails primary key convention
