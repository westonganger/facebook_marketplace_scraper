$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "fb_scraper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "fb_scraper"
  spec.version     = FBScraper::VERSION
  spec.authors     = ["Weston Ganger"]
  spec.email       = ["weston@westonganger.com"]
  #spec.homepage    = "https//github.com/westonganger/facebook_marketplace_scraper"
  spec.summary     = "Facebook marketplace scraper"
  spec.description = spec.summary
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib,public}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "slim"
  spec.add_dependency "nokogiri"
  spec.add_dependency "sprockets-rails"
  spec.add_dependency "playwright-ruby-client"
  spec.add_dependency "sqlite3"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "pry-byebug"
end
