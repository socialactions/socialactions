class Search < ActiveRecord::BaseWithoutTable
  column :q, :string
  #column :created, :integer
  column :limit, :integer
  column :order, :string
  column :match, :string
  column :show_blacklist, :boolean
  attr_accessor :sites, :kind, :ip_address
  attr_accessor :created
  attr_accessor :action_types, :exclude_action_types
  
  validates_inclusion_of :created, :in => %w{ 30 14 7 2 1 }
  
  Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
    :before_match => '<strong>',
    :after_match => '</strong>',
    :chunk_separator => "...",
    :limit => 200,
    :around => 3,
    :content_methods => [['title'],['description']]
  })
  
  VALID_SORT_FIELDS = ['title' , 'description', 'site_id', 'latitude', 'longitude', 'created_at', 'updated_at',
                        'hit_count', 'location', 'subtitle', 'goal_completed', 'goal_amount', 
                        'goal_type', 'goal_number_of_contributors', 'initiator_name', 'initiator_url', 'initiator_email', 'expires_at',
                        'dcterms_valid', 'platform_name', 'platform_url', 'platform_email', 'embed_widget', 
                        'organization_name', 'organization_email', 'tags', 'ein']

  def results(page)
    validate_input
    
    if kind == 'map'
      # figure out google map thing
      # Action.find(:all, :origin => [current_latitude, current_longitude], :conditions => build_conditions)
    else
      # TODO figure out random for sort_by
      Ultrasphinx::Search.new(
                                {:query => build_query,
                                 :weights => {:title => 12, :description => 12},
                                 :per_page => limit,
                                 :page => page || 1,
                                 :filters => build_filters
                                }.merge(build_sort)
                              ).run
    end
  end
  
  def to_s
    output = []
    output << "Query: #{q}" if q?
    output << "Created: #{created}" unless created.blank?
    output << "Action Types: #{action_types.each {|at| ActionType.find_by_id(at).name} }" if !action_types.empty?
    output << "Exclude Action Types: #{exclude_action_types.each {|eat| ActionType.find_by_id(eat).name} }" if !exclude_action_types.empty?
    output.join(', ')
  end
  
  def build_query
    query = q
    if match =='any'
      query = query.to_s.scan(/("[^"]*"|[^\s]+)/).join(' OR ')
    elsif !match.blank? and match != 'all'
      raise 'unknown value for match'
    end

    query
  end
  
  def build_filters
    filters = {}
    if show_blacklist.nil? || show_blacklist == false
      filters['blacklisted'] = 0
    end
    if sites.length > 0
      filters['site_id'] = sites
    end

    self.created = 'all' if created.blank?
    if created != 'all'
      self.created = created.to_i
      start_time = created == 0 ? Time.today.to_i : created.days.ago.to_i
      filters['created_at'] = start_time..Time.now.to_i
    end
    
    if action_types.length > 0 && exclude_action_types.length == 0
      filters['action_type_id'] = action_types
    elsif exclude_action_types.length > 0 && action_types.length == 0
      filters['action_type_id'] = ActionType.find_all_as_id_array.delete_if do |type_id| 
        exclude_action_types.include?(type_id.to_s)
      end
    end

    filters
  end
  
  def build_sort
    sort = {}
    
    if order == 'relevance' or order.blank?
        sort[:sort_mode] = 'relevance'
        sort[:sort_by] = nil
    elsif VALID_SORT_FIELDS.include?(order)
        sort[:sort_mode] = 'descending'
        sort[:sort_by] = order
    else
        raise 'unknown value for order'
    end
    
    sort
  end
  
  def sites
    @sites ||= []
  end

  def has_site?(site)
    return true if sites.empty?
    sites.include?(site.id.to_s)
  end
  
  def action_types
    @action_types ||= []
  end
  
  def exclude_action_types
    @exclude_action_types ||= []
  end
  
private
  def validate_input
    if action_types.length > 0 && exclude_action_types.length > 0 
      raise 'Can\'t designate action types and excluded action types in the same request!'
    end
  end
  
end
