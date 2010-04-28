require 'fastercsv'

class Shorturl::LogsController < ApplicationController
#  before_filter :login_required
  
  def index
    if params[:commit]  # a report was requested
      @results = {}
      condSQL = ''
      condParams = []
      
      unless params[:action_types].blank?
        action_type = ActionType.find(params[:action_types])
        @action_type = action_type.name
        condSQL << 'actions.action_type_id = ? '
        condParams.push action_type.id
      else
        @action_type = "All Actions"
      end
      
      unless params[:created].blank? or params[:created] == 'all'
        condSQL << '? < actions.created_at'
        condParams.push (Date.today - params[:created].to_i)
        if params[:created].to_i == 0
          @created = 'Today'
        else
          @created = "Within the last #{params[:created]} days"
        end
      else
        @created = "Any Time"
      end
      
      unless params[:sites].nil? or params[:sites].empty?
        sites = params[:sites].collect{|site_id| Site.find(site_id)}
        site_ids = sites.collect{|site| site.id}.join(',')
        condSQL << "actions.site_id IN (#{site_ids})"
        @sites = sites.collect{|site| site.name}.join(', ')
      else
        @sites = "All Sites"
      end
      
      @results[:num_actions] = Action.count(:conditions => [condSQL] + condParams)
      # weird rails bug: if both of these are enabled, we get ArgumentError "Shorturl is not missing constant Log!"
      # but if either one is enabled by itself, it works fine. WTF?
#      @results[:num_clicks] =       Log.count(:joins => 'INNER JOIN redirects ON logs.redirect_id = redirects.id INNER JOIN actions ON redirects.url = actions.url', :conditions => [condSQL] + condParams)
      @results[:unique_referrers] = Log.count(:joins => 'INNER JOIN redirects ON logs.redirect_id = redirects.id INNER JOIN actions ON redirects.url = actions.url', :conditions => [condSQL] + condParams, :distinct => true, :select => 'logs.referrer')
      # potentially interesting fields:
      # logs.referrer
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
