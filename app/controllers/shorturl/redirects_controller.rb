class Shorturl::RedirectsController < ApplicationController
  
  before_filter :login_required, :except => [:url, :slug]
  
  def url
    @redirect = Shorturl::Redirect.find_by_slug(params[:slug])
    if @redirect.nil? || @redirect.url.nil? || @redirect.blank?
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    else
      actions = Action.find(:all, :conditions => {:redirect_id => @redirect.id})
      action_id = (actions.empty? ? nil : actions.first.id)
      Shorturl::Log.new(:redirect_id => @redirect.id, :referrer => request.env["HTTP_REFERER"], :ip_address => request.env["REMOTE_ADDR"], :action_id => action_id).save
      if !actions.empty?
        actions.each do |action|
          #Action.increment_counter(:hit_count, action.id)
          if action.disabled 
            render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
            return
          end
          action.hit_count += 1
          action.save
        end
      end
      redirect_to @redirect.url
    end
  end
  
  def slug
    @redirect = Shorturl::Redirect.find_by_cookie_and_url(:cookie => params[:cookie], :url => params[:url])
    respond_to do |format|
      if !@redirect.nil?
        format.html { render :text => "http://#{@redirect.domain}/#{@redirect.slug}"}
        format.xml  { render :xml => {:url => "http://#{@redirect.domain}/#{@redirect.slug}"}}
      else
        format.html { render :text => 'slug doesn\'t exist', :status => 404 }
        format.xml  { render :xml => {:message => 'slug doesn\'t exist'}, :status => 404 }
      end
    end
  end

  # POST /shorturl_redirects
  # POST /shorturl_redirects.xml
  def create
    @redirect = Shorturl::Redirect.find_or_create_by_cookie_and_url(process_params)

    respond_to do |format|
      if @redirect.save
        format.html { render :text => "http://#{@redirect.domain}/#{@redirect.slug}", :status => :created }
        format.xml  { render :xml => {:url => "http://#{@redirect.domain}/#{@redirect.slug}"}, :status => :created, :location => @redirect }
      else
        format.html { render :text => @redirect.errors.each {|error| " #{error} "}, :status => :unprocessable_entity }
        format.xml  { render :xml => @redirect.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /shorturl_redirects
  # GET /shorturl_redirects.xml
  def index
    @shorturl_redirects = Shorturl::Redirect.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shorturl_redirects }
    end
  end



  # GET /shorturl_redirects/new
  # GET /shorturl_redirects/new.xml
  def new
    @redirect = Shorturl::Redirect.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @redirect }
    end
  end
  
  # GET /shorturl_redirects/1
  # GET /shorturl_redirects/1.xml
  #def show
  #  @redirect = Shorturl::Redirect.find(params[:id])

  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.xml  { render :xml => @redirect }
  #  end
  #end

  # GET /shorturl_redirects/1/edit
  #def edit
  #  @redirect = Shorturl::Redirect.find(params[:id])
  #end


  # PUT /shorturl_redirects/1
  # PUT /shorturl_redirects/1.xml
  #def update
  #  @redirect = Shorturl::Redirect.find(params[:id])

  #  respond_to do |format|
  #    if @redirect.update_attributes(params[:redirect])
  #      flash[:notice] = 'Shorturl::Redirect was successfully updated.'
  #      format.html { redirect_to(@redirect) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @redirect.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /shorturl_redirects/1
  # DELETE /shorturl_redirects/1.xml
  #def destroy
  #  @redirect = Shorturl::Redirect.find(params[:id])
  #  @redirect.destroy

  #  respond_to do |format|
  #    format.html { redirect_to(shorturl_redirects_url) }
  #    format.xml  { head :ok }
  #  end
  #end
  
private  
  def process_params
    my_params = {}
    if !params[:shorturl_redirect].nil?
      my_params[:url] = params[:shorturl_redirect][:url] if !params[:shorturl_redirect][:url].nil?
      my_params[:cookie] = params[:shorturl_redirect][:cookie] if !params[:shorturl_redirect][:cookie].nil?
    elsif !params[:redirect].nil?
      my_params[:url] = params[:redirect][:url] if !params[:redirect][:url].nil?
      my_params[:cookie] = params[:redirect][:cookie] if !params[:redirect][:cookie].nil? 
    else
      my_params = params
    end
    my_params
  end
  
end
