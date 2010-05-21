require 'fastercsv'

class Shorturl::LogsController < ApplicationController
  before_filter :login_required
  
  def index
    # set defaults
    @created_to = params[:created_to]
    if @created_to.blank?
      @created_to = Date.today.to_s
    end
    @created_from = params[:created_from]
    if @created_from.blank?
      @created_from = (Date.today << 6).to_s  # last 6 months
    end
    if params[:action_types].nil?
      # select all by default
      params[:action_types] = ActionType.find(:all).collect{|at| at.id.to_s}
      params[:select_all_action_types] = '1'
    end
    if params[:sites].nil?
      # select all by default
      params[:sites] = Site.find(:all).collect{|s| s.id.to_s}
      params[:select_all_sites] = '1'
    end
    if params[:commit]  # a report was requested
      @results = {}
      condSQL = ''
      condParams = []

      # actions' created date
      condSQL << 'actions.created_at BETWEEN ? AND ?'
      condParams.push @created_from, @created_to
      @created = "Between #{@created_from} and #{@created_to}"
      
      unless params[:action_types].nil? or params[:action_types].empty?
        action_types = params[:action_types].collect{|action_type_id| ActionType.find(action_type_id)}
        action_type_ids = action_types.collect{|action_type| action_type.id}.join(',')
        condSQL << " AND actions.action_type_id IN (#{action_type_ids})"
        if(action_types.length == ActionType.count)
          @action_types = "All Action Types"
        else
          @action_types = action_types.collect{|action_type| action_type.name}.join(', ')
        end
      else
        @action_types = "All Action Types"
      end
      
      unless params[:sites].nil? or params[:sites].empty?
        sites = params[:sites].collect{|site_id| Site.find(site_id)}
        site_ids = sites.collect{|site| site.id}.join(',')
        condSQL << " AND actions.site_id IN (#{site_ids})"
        if(sites.length == Site.count)
          @sites = "All Sites"
        else
          @sites = sites.collect{|site| site.name}.join(', ')
        end
      else
        @sites = "All Sites"
      end
      
      @results[:num_actions] = Action.count(:conditions => [condSQL] + condParams)
      # weird rails bug: if both of these are enabled, we get ArgumentError "Shorturl is not missing constant Log!"
      # but if either one is enabled by itself, it works fine. WTF?
      #joinSQL = 'INNER JOIN redirects ON logs.redirect_id = redirects.id INNER JOIN actions ON redirects.url = actions.url'
      joinSQL = 'INNER JOIN actions ON logs.action_id = actions.id'
      @results[:num_clicks] =       Shorturl::Log.count(:joins => joinSQL, :conditions => [condSQL] + condParams)
      @results[:unique_referrers] = Shorturl::Log.count(:joins => joinSQL, :conditions => [condSQL] + condParams, :distinct => true, :select => 'logs.referrer')
      @results[:unique_ipaddresses] = Shorturl::Log.count(:joins => joinSQL, :conditions => [condSQL] + condParams, :distinct => true, :select => 'logs.ip_address')
      # potentially interesting fields:
      # logs.created_at
    else
      @results = nil
    end
  end
  
  def show
    @logs = ["nothing"] # Shorturl::Log.find(:all)

    #########################################################
    # From this to END is temporary code, once we upgrade 
    # to Rails 2.1, delete and un-comment the respond_to block
    response.headers["Content-Type"] = 'text/csv'
    response.headers['Content-Disposition'] = "attachment; filename=index.csv" 
        
    result = FasterCSV.generate do |csv|
      csv << @logs[0].field_names

      @logs.each do |log|
        csv << log.field_values
      end
    end

    render :text => result
    # END the above is temporary code
    #########################################################

    #respond_to do |format|
    #  format.csv
    #end
  end
 
  def hits
    @redirect = Shorturl::Redirect.find_by_slug(params[:slug])
    respond_to do |format|
      if !@redirect.nil?
        format.html { render :text => "#{@redirect.logs.size}"}
        format.xml  { render :xml => {:hits => "#{@redirect.logs.size}"}}
      else
        format.html { render :text => 'slug doesn\'t exist', :status => 404 }
        format.xml  { render :xml => {:message => 'slug doesn\'t exist'}, :status => 404 }
      end
    end
  end
  
  def referrers
    @redirect = Shorturl::Redirect.find_by_slug(params[:slug])
    respond_to do |format|
      if !@redirect.nil?
        format.html { render :text => "#{@redirect.unique_referrers.join(", ")}"}
        format.xml  { render :xml => {:referrers => "#{@redirect.unique_referrers.join(", ")}"}}
      else
        format.html { render :text => 'slug doesn\'t exist', :status => 404 }
        format.xml  { render :xml => {:message => 'slug doesn\'t exist'}, :status => 404 }
      end
    end
  end
  
  # GET /shorturl_logs
  # GET /shorturl_logs.xml
  #def index
  #  @shorturl_logs = Shorturl::Log.find(:all)

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @shorturl_logs }
  #  end
  #end



  # GET /shorturl_logs/new
  # GET /shorturl_logs/new.xml
  #def new
  #  @log = Shorturl::Log.new

  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.xml  { render :xml => @log }
  #  end
  #end

  # GET /shorturl_logs/1/edit
  #def edit
  #  @log = Shorturl::Log.find(params[:id])
  #end

  # POST /shorturl_logs
  # POST /shorturl_logs.xml
  #def create
  #  @log = Shorturl::Log.new(params[:log])

  #  respond_to do |format|
  #    if @log.save
  #      flash[:notice] = 'Shorturl::Log was successfully created.'
  #      format.html { redirect_to(@log) }
  #      format.xml  { render :xml => @log, :status => :created, :location => @log }
  #    else
  #      format.html { render :action => "new" }
  #      format.xml  { render :xml => @log.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # PUT /shorturl_logs/1
  # PUT /shorturl_logs/1.xml
  #def update
  #  @log = Shorturl::Log.find(params[:id])

  #  respond_to do |format|
  #    if @log.update_attributes(params[:log])
  #      flash[:notice] = 'Shorturl::Log was successfully updated.'
  #      format.html { redirect_to(@log) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @log.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /shorturl_logs/1
  # DELETE /shorturl_logs/1.xml
  #def destroy
  #  @log = Shorturl::Log.find(params[:id])
  #  @log.destroy

  #  respond_to do |format|
  #    format.html { redirect_to(shorturl_logs_url) }
  #    format.xml  { head :ok }
  #  end
  #end
end
