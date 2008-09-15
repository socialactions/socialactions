require 'pp'

class DonorsChooseParser
  attr_accessor :feed

  def json
    @json ||= ActiveSupport::JSON.decode(open(feed.url, 'User-Agent' => 'SocialActions').read)
  end
  
  def parse
    pp json
    
  end

  def self.parse(feed)
    parser = new
    parser.feed = feed
    parser.parse
  end

end
