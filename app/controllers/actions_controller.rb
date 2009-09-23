class ActionsController < ApplicationController
  
  before_filter :login_required, :except => :index
  before_filter :api_key_required, :only => :index
  
  def index
    begin
      @search = Search.new(search_params)
      @actions = @search.results(params[:page])
      #request.env.each {|key,value| warn "env[#{key}] = '#{value}'"}
      json_array = []
      if params[:just_stats].nil?
        json_array = @actions.results
      else
        json_array = [{ :result_count => @actions.total_entries, :page_count => "#{@actions.total_entries / @search.limit}" }]
      end
      respond_to do |format|
        format.html { @actions.excerpt }
        format.json { render :json => json_array.to_json(Action.json_options) }
        format.js   { render_jsonp json_array.to_json(Action.json_options) }
        format.rss
        format.atom
      end
    rescue Exception => message
      # not the best rescue ever, as it always assumes status 400
      headers['Content-Type'] = 'text/plain'
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
  
  def blacklist
    action = Action.find_by_id(params[:id])
    action.blacklisted = true
    action.save!
    redirect_to :action => 'show', :id => params[:id]
  end
  
  def unblacklist
    action = Action.find_by_id(params[:id])
    action.blacklisted = false
    action.save!
    redirect_to :action => 'show', :id => params[:id]
  end
  
  def show
    #redirect_to :action => 'index'
    @action = Action.find(params[:id])
    respond_to do |format|
      format.html
    #  format.xml
    end    
  end
  
end

