require 'fastercsv'

class Shorturl::LogsController < ApplicationController
 
  def show
    @logs = Shorturl::Log.find(:all)

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
    # END the above is temorary code
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
