class RemoveInvalidActions < ActiveRecord::Migration
  # remove actions which link to invalid (deleted) feeds
  def self.up
    feed_ids = Feed.find(:all).map{|f| f.id}
    Action.destroy_all(['feed_id NOT IN (?)', feed_ids])
  end

  def self.down
  end
end
