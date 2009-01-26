class AddRedirectIdToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :redirect_id, :integer
  end

  def self.down
    remove_column :actions, :redirect_id
  end
end
