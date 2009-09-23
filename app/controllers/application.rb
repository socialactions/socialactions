# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem
  include ApiKeySystem
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1a6bbb367383c24380852761da6c194f'
  
  helper_method :search_params
  helper_method :search_params_readable
  
  def search_params
    params[:order] = 'created_at' if params[:order].blank?
    params[:limit] = '10' if params[:limit].blank? || params[:limit].to_i <= 0
    params[:limit] = '50' if params[:limit].to_i > 50 
    params[:sites] = params[:sites].split(',') if (params[:sites].is_a? String)
    params[:show_blacklist] = logged_in? ? 'true' : 'false'
    if !logged_in? && params[:show_only_blacklist] == 'true'
      params[:show_only_blacklist] = 'false'
    end
    params[:action_types] = params[:action_types].split(',') if (params[:action_types].is_a? String)
    params[:exclude_action_types] = params[:exclude_action_types].split(',') if (params[:exclude_action_types].is_a? String)
    params.slice(:q, :action_types, :exclude_action_types, :created, :sites, :show_blacklist, :show_only_blacklist, :kind, :ip_address, :limit, :order, :match).delete_if{|k,v| v.nil? || v.empty?}
  end

  def search_params_readable
    params = search_params
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
