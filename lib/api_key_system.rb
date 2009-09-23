module ApiKeySystem
  def api_key_required
    if params[:format] == 'json' || params[:format] == 'js'
      api_authorized? || api_access_denied
    end
  end
  
  def api_authorized?
      if params[:key].nil?
        # Temorarily allowing json without key, but not jsonp
        return params[:format] == 'js' ? false : true
      end
      request.env.each {|key,value| warn "env[#{key}] = '#{value}'" }
      @api_key = ApiKey.find_by_key(params[:key])
      @api_key.validate_host(request.env)
  end
  
  def api_access_denied
    warn "access for key '#{params[:key]}' denied (env below)"
    request.env.each {|key,value| warn "env[#{key}] = '#{value}'" }
    redirect_to access_denied_url()
  end
end