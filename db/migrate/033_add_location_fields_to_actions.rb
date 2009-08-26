class AddLocationFieldsToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :location_city, :string
    add_column :actions, :location_country, :string
    add_column :actions, :location_state, :string
    add_column :actions, :location_postalcode, :string
  end

  def self.down
    remove_column :actions, :location_city
    remove_column :actions, :location_country
    remove_column :actions, :location_state
    remove_column :actions, :location_postalcode
  end
end
