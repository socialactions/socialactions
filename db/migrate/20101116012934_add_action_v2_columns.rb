class AddActionV2Columns < ActiveRecord::Migration
  def self.up
    add_column :actions, :entities, :text
    add_column :actions, :nlp_result, :text
  end

  def self.down
    remove_column :actions, :entities
    remove_column :actions, :nlp_result
  end
end
