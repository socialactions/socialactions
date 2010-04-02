class AddDisabledOnToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :disabled_on, :date
  end

  def self.down
    remove_column :actions, :disabled_on
  end
end
