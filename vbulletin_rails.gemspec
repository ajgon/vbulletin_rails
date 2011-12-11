$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "vbulletin_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "vbulletin_rails"
  s.version     = VBulletinRails::VERSION
  s.authors     = ["Igor Rzegocki"]
  s.email       = ["igor.rzegocki@gmail.com"]
  s.homepage    = "https://github.com/ajgon/vbulletin_rails"
  s.summary     = "VBulletin integration for Rails"
  s.description = ""

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency "rails", ">= 3.0"
  s.add_dependency "mysql2"
end
