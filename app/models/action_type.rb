class ActionType < ActiveRecord::Base
  has_many :actions
  has_many :feeds
  
  def self.find_all_as_name_id_array
    action_types = self.find(:all)
    arrary_of_name_id_arrays = []
    action_types.each do |action_type|
      arrary_of_name_id_arrays << [action_type.name,action_type.id]
    end
    arrary_of_name_id_arrays
  end
  
  def self.find_all_as_id_array
    action_types = self.find(:all)
    arrary_of_ids = []
    action_types.each do |action_type|
      arrary_of_ids << action_type.id
    end
    arrary_of_ids
  end
  
  def self.json_options
    { :only => [:name, 
                :id]
    }
  end
end
