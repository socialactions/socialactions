require 'open-uri'
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
    @feed ||= FeedParser.parse(url, :agent => 'SocialActions')
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
