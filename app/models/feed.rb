require 'open-uri'
require 'rfeedparser'

class Feed < ActiveRecord::Base
  belongs_to :site
  belongs_to :action_type
  has_many :actions

  def parse
    if is_donorschoose_json?
      DonorsChooseParser.parse(self)
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
    @feed ||= FeedParser.parse(open(url, 'User-Agent' => 'SocialActions'))
  end

  class << self
    def parse_all(options = {})
      conditions = options[:all] ? nil : ['needs_updating = 1']
      find(:all, :conditions => conditions).each do |feed| 
        puts "Parsing #{feed.name}"
        #begin
          feed.parse
        #rescue
        #  puts "ERROR on feed #{feed.name}: #{$!}"
        #end
      end
    end
  end
end
