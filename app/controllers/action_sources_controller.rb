class ActionSourcesController < ApplicationController
  
  before_filter :login_required
  before_filter :init_vals
  
  # GET /action_sources
  # GET /action_sources.xml
  def index
    @action_sources = ActionSource.find(:all, :include => :site, :order => 'sites.name,action_sources.name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @action_sources }
    end
  end

  # GET /action_sources/1
  # GET /action_sources/1.xml
  def show
    @action_source = ActionSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @action_source }
    end
  end

  # GET /action_sources/new
  # GET /action_sources/new.xml
  def new
    @action_source = ActionSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @action_source }
    end
  end

  # GET /action_sources/1/edit
  def edit
    @action_source = ActionSource.find(params[:id])
  end

  # POST /action_sources
  # POST /action_sources.xml
  def create
    @action_source = ActionSource.new(params[:action_source])
    if !params[:site].nil?
      @site = Site.new(params[:site])
      @action_source.site = @site
    end
    if !params[:action_type].nil?
      @action_type = ActionType.new(params[:action_type])
      @action_source.action_type = @action_type
    end
    respond_to do |format|
      if @action_source.save
        flash[:notice] = 'ActionSource was successfully created.'
        format.html { redirect_to(@action_source) }
        format.xml  { render :xml => @action_source, :status => :created, :location => @action_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @action_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /action_sources/1
  # PUT /action_sources/1.xml
  def update
    @action_source = ActionSource.find(params[:id])
    if !params[:site].nil?
      @site = Site.new(params[:site])
      @action_source.site = @site
    end
    if !params[:action_type].nil?
      @action_type = ActionType.new(params[:action_type])
      @action_source.action_type = @action_type
    end
    respond_to do |format|
      if @action_source.update_attributes(params[:action_source])
        flash[:notice] = 'ActionSource was successfully updated.'
        format.html { redirect_to(@action_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @action_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /action_sources/1
  # DELETE /action_sources/1.xml
  def destroy
    @action_source = ActionSource.find(params[:id])
    @action_source.destroy

    respond_to do |format|
      format.html { redirect_to(action_sources_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def init_vals
    if !params[:site_name].blank? && !params[:site_url].blank?
      params[:site] = {:name => params[:site_name], :url => params[:site_url]}
    end
    if !params[:action_type_name].blank?
      params[:action_type] = {:name => params[:action_type_name]}
    end
  end
end
