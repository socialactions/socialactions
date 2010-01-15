class Site < ActiveRecord::Base
  has_many :action_sources
  
  validates_presence_of :name
  validates_presence_of :url
  
  def disabled=(bit)
    self.action_sources.each do |action_source|
      # we check before we set for performance reasons. setting disabled
      # on an action source makes it iterate through all actions and disable
      # them as well. So, if it's not necessary, let's not do it.
      unless action_source.disabled == bit
        action_source.disabled = bit 
        action_source.save
      end
    end
    write_attribute(:disabled, bit)
    self.save
  end
  
  def has_enabled_action_sources?
    self.action_sources.each do |action_source|
      return true if !action_source.disabled
    end
    return false
  end
  
  def ensure_state
    if !self.disabled && !self.has_enabled_action_sources?
      self.disabled = true
      self.save
    elsif self.disabled && self.has_enabled_action_sources?
      self.disabled = false
      self.save
    end
  end
  
  def self.find_all_as_name_id_array
    sites = self.find(:all, :order => 'name', :conditions => {:disabled => false})
    arrary_of_name_id_arrays = []
    sites.each do |site|
      arrary_of_name_id_arrays << [site.name,site.id]
    end
    arrary_of_name_id_arrays
  end
  
  def self.json_options
    { :only => [:name,
                :id]
    }
  end
  
end
