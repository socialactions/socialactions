require 'rfeedparser'
require 'feedparser_rssa_patch'

class Feed < ActiveRecord::Base
  belongs_to :site
  belongs_to :action_type
  has_many :actions

  def parse
    if is_donorschoose_json?
      DonorsChooseParser.new(self).parse
    else
      feed.items.each do |entry|
        action = actions.find_or_create_by_url(entry.link)
        action.update_from_feed_entry(entry)
        action.save!
      end
    end

    update_attribute(:needs_updating, false)
  end

  def feed
    return @feed if @feed

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get(uri.path, 'User-Agent' => 'SocialActions')

    @feed = FeedParser.parse(res.body)
  end

  class << self
    def parse_all(options = {})
      conditions = options[:all] ? nil : ['needs_updating = 1']
      find(:all, :conditions => conditions).each do |feed| 
        puts "Parsing #{feed.name}" if options[:debug]
        begin
          feed.parse
        rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Timeout::Error
          puts "ERROR on feed #{feed.name}: #{$!}"
        end
      end
    end
  end
end
