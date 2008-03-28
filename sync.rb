#!/usr/bin/ruby
require 'yaml'

feeds = YAML::load(File.open('sync.yml', 'r'))

args = ['./opmldiff']

for feed in feeds
  
  local = feed["local"]
  remote = feed["remote"]
  
  puts "Synchronising #{local} with #{remote}"
  
  args << local
  args << remote
  
end

args << "> diff.xml"

`#{args.join(" ")}`

puts "Complete"