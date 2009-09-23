require 'rfeedparser'
require 'open-uri'
require 'zip/zip'

module IdealistFileFeed
  # http://feeds.idealist.org/xml/feeds/Idealist-VolunteerOpportunity-VOLUNTEER_OPPORTUNITY_TYPE.en.open.atom.gz
  FILE_NAME = "#{RAILS_ROOT}/tmp/idealist.atom.gz"
  
  def parse
    puts "parsing"
    feed.items.each do |entry|
      #populate_action(entry)
      puts "entry: #{entry.title}" 
    end
    update_attribute(:needs_updating, false)
  end

  def feed
    @feed ||= FeedParser.parse(get_feed_file)
  end
  
  def get_feed_file
    Zlib::GzipReader.open(FILE_NAME).read
  end
  
  def get_remote_file
    f = File.new(FILE_NAME, "w+")
    f.binmode
    f.write open(url).read
    f.close
    FILE_NAME
  end
  
  
end