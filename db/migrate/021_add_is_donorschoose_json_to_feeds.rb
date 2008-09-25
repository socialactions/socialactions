class AddIsDonorschooseJsonToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :is_donorschoose_json, :boolean, :default => false
  end
  
  def self.down
    remove_column :feeds, :is_donorschoose_json
  end
end
