class RefactorActionType < ActiveRecord::Migration
  def self.up
    create_table :action_types do |t|
      t.string :name
      
      t.timestamps
    end
    
    rename_column :actions, :action_type, :action_type_old
    add_column :actions, :action_type_id, :integer
    rename_column :feeds, :action_type, :action_type_old
    add_column :feeds, :action_type_id, :integer
    
    # do data migration
    Action.reset_column_information
    Feed.reset_column_information
    ActionType.reset_column_information
    actions = Action.find(:all)
    feeds = Feed.find(:all)
    
    records = feeds + actions 
    records.each do |record|
      record.action_type = ActionType.find_or_create_by_name(record.action_type_old)
      record.save!
    end
    # end data migration
    
    remove_column :actions, :action_type_old
    remove_column :feeds, :action_type_old
    add_index(:action_types, [:id, :name], :unique => true)
    add_index(:action_types, [:name], :unique => true)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "This migration changes the database in a way that changes the Model classes. 
                                                It is therefore irreversible as the new Model classes do not work with the old database structure."
  end
end
