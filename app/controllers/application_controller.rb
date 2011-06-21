# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem
  include ApiKeySystem
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  helper_method :get_search_params
  helper_method :get_search_params_readable

  def get_search_params
    #params[:order] = 'created_at' if params[:order].blank?
    params.delete(:match) # a piece from legacy code for backwards compatibility
    params[:limit] = '10' if params[:limit].blank? || params[:limit].to_i <= 0
    params[:limit] = '50' if params[:limit].to_i > 50
    params[:show_disabled] = logged_in? ? 'true' : 'false'
    if !logged_in? && params[:show_only_disabled] == 'true'
      params[:show_only_disabled] = 'false'
    end

    params[:sites] = params[:sites].split(',') if (params[:sites].is_a? String)
    params[:exclude_sites] = params[:exclude_sites].split(',') if (params[:exclude_sites].is_a? String)

    params[:action_types] = params[:action_types].split(',') if (params[:action_types].is_a? String)
    params[:exclude_action_types] = params[:exclude_action_types].split(',') if (params[:exclude_action_types].is_a? String)

    params.slice(:q, :action_types, :exclude_action_types, :created, :sites, :exclude_sites,
      :show_disabled, :show_only_disabled, :kind, :ip_address, :limit, :order, :match, :coordinates, :distance).
      delete_if{|k,v| v.nil? || v.empty?}
  end

  def get_search_params_readable
    params = get_search_params
    params[:sites] = params[:sites].join(',') if (params[:sites] and params[:sites].is_a? Hash)
    params
  end

protected
  def render_jsonp(json, options={})
    callback, variable = sanitize_var(params[:callback]), sanitize_var(params[:variable])
    response = begin
      if callback && variable
        "var #{variable} = #{json};\n#{callback}(#{variable});"
      elsif variable
        "var #{variable} = #{json};"
      elsif callback
        "#{callback}(#{json});"
      else
        json
      end
    end
    render({:content_type => :js, :text => response}.merge(options))
  end

  def sanitize_var(var)
    var.gsub(/ /,'').gub(/\./,'')
  end

end
