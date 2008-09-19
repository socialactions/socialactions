class AddEinToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :ein, :string
  end

  def self.down
    remove_column :actions, :ein
  end
end
