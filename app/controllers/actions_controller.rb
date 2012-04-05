class ActionsController < ApplicationController
  
  before_filter :login_required, :except => [:index]
  before_filter :api_key_required, :only => :index
  
  def index
    begin
      search_params = get_search_params
      @search = Search.new(search_params)
      search_result = @search.result(params[:page])
      @result = search_result
      @actions = search_result.results
      #request.env.each {|key,value| warn "env[#{key}] = '#{value}'"}
      json_array = []

      if params[:just_stats].nil?
        search_result.hits.each{|h| h.result.score = h.score unless h.result.nil?}
        json_array = search_result.hits.map{|h| h.result}
      else
        json_array = [{:result_count => search_result.total, :page_count => (search_result.total / @search.limit.to_i + 1)}]
      end

      if RAILS_ENV == 'development'
        logger.debug "solr_result: " + search_result.solr_result.to_yaml
      end

      respond_to do |format|
        format.html
        format.json { render :json => json_array.to_json(Action.json_options) }
        format.js   { render_jsonp json_array.to_json(Action.json_options) }
        format.xml
        format.rss
        format.atom
      end
    rescue Exception => exc
      # not the best rescue ever, as it always assumes status 400
      headers['Content-Type'] = 'text/plain'
      logger.warn "FFFFFUUUUU"
      logger.warn exc
      render :text => exc.to_s, :status=>400
    end
  end
  
  def random
    @search = Search.new(get_search_params.merge(:kind => 'random'))
    @actions = @search.result(params[:page]).results
    if @actions.empty?
      redirect_to(:back)
    else
      redirect_to @actions.first.url
    end
  end
  
  def disable
    action = Action.find_by_id(params[:id])
    action.disabled = true
    action.save!
    redirect_to :action => 'show', :id => params[:id]
  end
  
  def enable
    @action = Action.find_by_id(params[:id])
    @action.disabled = false
    @action.save
    if @action.errors.size > 0
      flash[:error] = @action.errors.full_messages.join(", ")
      @action.disabled = true
    end
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

  def set_entity
    entity_name = CGI.unescape params['entity']['name']
    entity = @action.entities[params['entity']['type']].select{|e| e['name'] == entity_name}.first
    @entity = {
      :type => params['entity']['type'],
      :name => entity['name'],
      :relevance => entity['relevance']
    }
    @entity.merge!({
      :latitude => entity['latitude'],
      :longitude => entity['longitude']
    }) if @entity[:type] == 'geolocations'

  end
  protected :set_entity

  def new_entity
    @new_entity = true
    @action = Action.find(params[:id])
    @entity = {
      :type => '',
      :name => '',
      :relevance => 0
    }
    @entity.merge!({
      :latitude => entity['latitude'],
      :longitude => entity['longitude']
    }) if @entity[:type] == 'geolocations'
    render :action => 'edit_entity'
  end

  def create_entity
    @action = Action.find(params[:id])

    if @action.create_entity params['entity']
      redirect_to :action => 'show'
    else
      @new_entity = true
      @entity = {
        :type => params['entity']['type'],
        :name => params['entity']['name'],
        :relevance => params['entity']['relevance']
      }
      render :action => 'edit_entity'
    end
  end

  def edit_entity
    @action = Action.find(params[:id])
    begin
      set_entity
    rescue
      raise "Not found"
    end
  end

  def update_entity
    @action = Action.find(params[:id])

    if @action.update_entity params['entity']
      redirect_to :action => 'show'
    else
      set_entity
      render :action => 'edit_entity'
    end
  end

  def delete_entity
    action = Action.find(params[:id])
    action.delete_entity params['entity']
    action.save!
    redirect_to :action => 'show'
  end

  def rescan
    action = Action.find(params[:id])
    action.update_entities
    redirect_to :action => 'show'
  end
  
end

