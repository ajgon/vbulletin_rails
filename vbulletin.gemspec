$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "vbulletin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "vbulletin"
  s.version     = Vbulletin::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Vbulletin."
  s.description = "TODO: Description of Vbulletin."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0"
  s.add_dependency "mysql2"
end
