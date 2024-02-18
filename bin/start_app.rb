#!/usr/bin/env ruby

puts "########################################"
puts "Facebook Marketplace Scraper"
puts "########################################"

puts "App starting up"

system("ln -s node_modules/ spec/dummy/")
system("bundle exec rails db:migrate")

puts "App running"
puts "Go to http://localhost:3000/"
puts "\n"

system("FB_SCRAPER_LOG_LEVEL=warn bundle exec rails s", out: STDOUT)
