class Site < ActiveRecord::Base
  has_many :feeds
  
  validates_presence_of :name
  validates_presence_of :url
  
  def self.find_all_as_name_id_array
    sites = self.find(:all, :order => 'name')
    arrary_of_name_id_arrays = []
    sites.each do |site|
      arrary_of_name_id_arrays << [site.name,site.id]
    end
    arrary_of_name_id_arrays
  end
end
