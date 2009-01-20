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
    @feed ||= FeedParser.parse(fetch(url).body)
  end

  def fetch(furl, depth=0)
    uri = URI.parse(furl)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get(uri.request_uri, 'User-Agent' => 'SocialActions')

    if res.is_a?(Net::HTTPRedirection)
      raise "redirect loop" if depth > 5

      if res.is_a?(Net::HTTPMovedPermanently)
        warn "301 Permanent Redirect for #{name} to #{res.header['location']} - updating db" 
        self.update_attribute(:url, res.header['location'])
      end

      return fetch(res.header['location'], depth+1)
    end

    unless res.is_a? Net::HTTPSuccess
      raise "#{res.code} #{res.message}"
    end

    res
  end

  class << self
    def parse_all(options = {})
      conditions = options[:all] ? nil : ['needs_updating = 1']
      find(:all, :conditions => conditions).each do |feed| 
        puts "Parsing #{feed.name}" if options[:debug]
        begin
          feed.parse
        rescue
          puts "ERROR on feed #{feed.name}: #{$!}"
        end
      end
    end
  end
end
