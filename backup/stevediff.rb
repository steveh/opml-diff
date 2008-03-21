#!/usr/bin/ruby

require 'pathname'
require 'rubygems'
require "rexml/document"
require 'open-uri'
require 'builder'

class Pair

  attr_accessor :name, :opml1, :opml2, :backup

  def initialize(name, opml1, opml2)
	  @name, @opml1, @opml2 = name, Pathname.new(opml1), Pathname.new(opml2)
	  @backup = @opml1.dirname + (@opml1.basename.to_s + '.backup')
  end

end

pairs = []
feeds = []

pairs << Pair.new("NZTech", "nztech.xml", "http://planet.nztech.org/opml.xml")
pairs << Pair.new("Intertwingly", "intertwingly.xml", "http://planet.intertwingly.net/opml.xml")

for pair in pairs

  raise "Original OPML file must be readable" unless pair.opml1.readable?
  
  raise "Original OPML file must be writable" unless pair.opml1.writable?
  
  if pair.backup.exist?
    raise "Backup OPML file must be writable" unless pair.backup.writable?
  else
    raise "Backup directory must be writable" unless pair.backup.dirname.writable?
  end
  
  existing_feed_urls = []
  existing_opml = REXML::Document.new open(pair.opml1.to_s)
  existing_opml.elements.each('/opml/body/outline') do |feed|
    existing_feed_urls << feed.attributes['xmlUrl']
  end

  new_opml = REXML::Document.new open(pair.opml2.to_s)
  new_opml.elements.each('/opml/body/outline') do |feed|
    feeds << feed unless existing_feed_urls.include? feed.attributes['xmlUrl']
  end

  File.copy pair.opml1, pair.backup
  
  File.open(pair.opml1, 'w') { |f| f.write(new_opml.to_s) }
  
end

xml = Builder::XmlMarkup.new(:target => $stdout, :indent => 2)
xml.instruct!
xml.opml do
  xml.head do
    xml.title "OPMLDiff"
    xml.dateModified Time.now
    xml.ownerName "Steve Hoeksema"
    xml.ownerEmail "steve@seven.net.nz"
  end
  xml.body do
    for feed in feeds do
      xml.outline(
        :type => feed.attributes['type'],
        :text => feed.attributes['text'],
        :title => feed.attributes['title'],
        :xmlUrl => feed.attributes['xmlUrl']
      )
    end
  end
end