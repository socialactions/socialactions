class Search < ActiveRecord::BaseWithoutTable
  column :q, :string
  #column :created, :integer
  column :limit, :integer
  column :order, :string
  #column :match, :string
  column :coordinates, :string
  column :distance, :string
  column :show_disabled, :boolean
  column :show_only_disabled, :boolean
  attr_accessor :sites, :exclude_sites
  attr_accessor :kind, :ip_address
  attr_accessor :created
  attr_accessor :action_types, :exclude_action_types
  
  validates_inclusion_of :created, :in => %w{ 30 14 7 2 1 }
  
  VALID_SORT_FIELDS = [
    :title, :created_at, :updated_at, :expires_at, :hit_count, :location, :site_id,
    :goal_amount, :goal_completed, :goal_number_of_contributors,
    :longitude, :latitude
  ]

  def result(page)
    validate_input
    
    if false && kind == 'map'
      # figure out google map thing
      # Action.find(:all, :origin => [current_latitude, current_longitude], :conditions => build_conditions)
    else
      # TODO figure out random for sort_by
      search = Sunspot.search Action do
        # Note block_uri_tokenization workaround: see comment in string_ext.rb
        kwds = q.to_s.downcase.block_uri_tokenization.gsub(/\^\d+/, '')
        keywords kwds do
          highlight :title
          highlight :stripped_description, :max_snippets => 3, :fragment_size => 200
        end

        adjust_solr_params do |params|
          # Make posts 90 days old 1/2 the score
          params[:bf] = "recip(ms(NOW,created_at_dt),1.28e-10,1,1)"

          raw_tokens = q.to_s.downcase.block_uri_tokenization.
            scan(/\"[^\"]+\"|[^\W\"]+/).
            map{|s| '"' + s.strip.gsub(/"|^[+-]|\^\d+$/, '').gsub(/\^\d+$/, '') + '"'}
          params[:bq] = "all_text_texts:(#{raw_tokens.join(' OR ')})"
          params[:mm] = "0"

          if RAILS_ENV == 'development'
            params[:debugQuery]= 'true'
          end
        end

        paginate :page => page || 1, :per_page => limit

        if show_disabled.nil? || show_disabled == false
          without :disabled, true
        end
        if !show_only_disabled.nil? && show_only_disabled == true
          with :disabled, true
        end

        self.created = 'all' if created.blank?
        if created != 'all'
          self.created = created.to_i
          start_time = created == 0 ? Time.now.midnight : created.days.ago
          with(:created_at).greater_than start_time
        end

        if sites.length > 0 && exclude_sites.length == 0
          with(:site_id).any_of sites
        elsif exclude_sites.length > 0 && sites.length == 0
          without(:site_id).any_of exclude_sites
        end

        if action_types.length > 0 && exclude_action_types.length == 0
          with(:action_type_id).any_of(action_types)
        elsif exclude_action_types.length > 0 && action_types.length == 0
          without(:action_type_id).any_of(exclude_action_types)
        end

        sort_order = order.blank? ? nil : order.to_s.downcase.to_sym
        if q.blank? && sort_order.blank? || sort_order == :date
          order_by :created_at, :desc
        elsif sort_order == :relevance || sort_order.blank?
          # Default
        elsif sort_order == :popularity
          order_by :hit_count, :desc
        elsif VALID_SORT_FIELDS.include?(sort_order)
          order_by sort_order, :desc
        else
          raise 'unsupported value for order'
        end
      end
      search
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
  
  def sites
    @sites ||= []
  end

  def exclude_sites
    @exclude_sites ||= []
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

    if sites.length > 0 && exclude_sites.length > 0
      raise 'Can\'t designate sites and excluded sites in the same request!'
    end
  end
  
end
