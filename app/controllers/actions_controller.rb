class ActionsController < ApplicationController
  
  helper_method :search_params
  
  def search_params
    params[:order] = 'created_at' if params[:q].blank?
    params[:limit] = '10' if params[:limit].blank?
    params[:sites] = params[:sites].split(',') if (params[:sites].is_a? String)
    params[:action_types] = params[:action_types].split(',') if (params[:action_types].is_a? String)
    params[:exclude_action_types] = params[:exclude_action_types].split(',') if (params[:exclude_action_types].is_a? String)
    params.slice(:q, :action_types, :exclude_action_types, :created, :sites, :kind, :ip_address, :limit, :order, :match).delete_if{|k,v| v.nil? || v.empty?}
  end
  
  def index
    begin
      @search = Search.new(search_params)
      @actions = @search.results(params[:page])
      respond_to do |format|
        format.html { @actions.excerpt }
        format.json  { render :json => @actions.results.to_json(Action.json_options) }
        format.rss { render :layout => false }
      end
    rescue Exception => message
      # not the best rescue ever, as it always assumes status 400
      render :text => message, :status=>400
    end
  end
  
  def random
    @search = Search.new(search_params.merge(:kind => 'random'))
    @actions = @search.results(params[:page])
    if @actions.empty?
      redirect_to(:back)
    else
      redirect_to(@actions.first.url)
    end
  end
  
  def show
    @action = Action.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false}
      format.xml
    end    
  end

end

