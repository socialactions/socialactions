class Search < ActiveRecord::BaseWithoutTable
  column :q, :string
  column :action_type, :string
  #column :created, :integer
  column :limit, :integer
  column :order, :string
  column :match, :string
  attr_accessor :sites, :kind, :ip_address
  attr_accessor :created
  
  validates_inclusion_of :created, :in => %w{ 30 14 7 2 1 }
  
  Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
    :before_match => '<strong style="color:red">',
    :after_match => '</strong>',
    :chunk_separator => "...",
    :limit => 200,
    :around => 3,
    :content_methods => [['title'],['description']]
  })

  def results(page)
    if kind == 'map'
      Action.find(:all, :origin => [current_latitude, current_longitude], :conditions => build_conditions)
    else
      if order == 'relevance' or order.blank?
        sort_mode = 'relevance'
        sort_by = nil
      elsif order == 'created_at'
        sort_mode = 'descending'
        sort_by = 'created_at'
      else
        raise 'unknown value for order'
      end

      # TODO figure out random for sort_by
      Ultrasphinx::Search.new(
                              :query => build_query,
                              :per_page => limit,
                              :page => page || 1,
                              :sort_mode => sort_mode,
                              :sort_by => order,
                              :filters => build_filters,
                              :facets => ['action_type']
                              #, :weights => {}
                              ).run
    end
  end
  
  def to_s
    output = []
    output << "Query: #{q}" if q?
    output << "Created: #{created}" unless created.blank?
    output << "Action Type: #{action_type}" if action_type?
    output.join(', ')
  end
  
  def build_query
    query = q
    if match =='any'
      query = query.scan(/("[^"]*"|[^\s]+)/).join(' OR ')
    elsif !match.blank? and match != 'all'
      raise 'unknown value for match'
    end

    unless action_type.nil? or action_type == 'all'
      "action_type:\"#{action_type}\" AND (#{query})"
    else
      query
    end
  end
  
  def build_filters
    filters = {}
    if sites.length > 0
      filters['site_id'] = sites
    end
    self.created = 7 if created.blank?
    if created != 'all'
      start_time = created.to_i == 0 ? Time.today.to_i : created.to_i.days.ago.to_i
      filters['created_at'] = start_time..Time.now.to_i
    end
    filters
  end

  def build_conditions
    reset_conditions
    add_q
    add_action_type
    add_sites
    add_created
    add_mapping
    conditions.join(' AND ')
  end
  
  def build_order
    kind == 'random' ? 'RAND()' : 'created_at DESC'
  end
  
  def sites
    @sites ||= []
  end

  def has_site?(site)
    return true if sites.empty?
    sites.include?(site.id.to_s)
  end

  def reset_conditions
    @conditions = []
  end

  def conditions
    @conditions ||= []
  end

  def add_q
    unless q.nil? or q.empty?
      keyword_conditions = []
      q.split(' ').each do |keyword|
        keyword_conditions << sanitize(["(description LIKE ? OR title LIKE ?)", "%#{keyword}%", "%#{keyword}%"])
      end
      conditions << "(" + keyword_conditions.join(' OR ') + ")"
    end
  end
  
  def add_action_type
    unless action_type.nil? or action_type == 'all'
      conditions << "action_type = '#{action_type}'"
    end
  end
  
  def add_sites
    unless sites.nil? or sites.empty?
      conditions << sanitize(["site_id IN (?)", sites])
    end
  end
  
  def add_created
    unless created.nil?
      conditions << sanitize(["actions.created_at > ?", created.days.ago])
    end
  end
  
  def add_mapping
    if kind == 'map'
      conditions << 'latitude IS NOT NULL and longitude IS NOT NULL'
    end
  end
  
  def sanitize(arg)
    ActiveRecord::Base.send(:sanitize_sql, arg)
  end
  
  def current_latitude
    current_location.lat || 21.98
  end
  
  def current_longitude
    current_location.lng || -10.00
  end
  
  def current_location
    # debugger
    @current_location ||= GeoKit::Geocoders::IpGeocoder.geocode(current_ip)
  end
  
  def current_ip
    ip_address == '127.0.0.1' ? '67.162.124.13' : ip_address
  end
  
  # def get_current_location
  #   location = GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip)
  #   unless location.lat.nil? and location.lng.nil?
  #     return location.lat, location.lng
  #   else
  #     return 41.98, -87.90 # Chicago, an estimate
  #   end
  # end
  
end
