class ActionTypesController < ApplicationController
  
  before_filter :login_required, :except => [:index]
  
  # GET /action_types
  # GET /action_types.xml
  def index
    @action_types = ActionType.find(:all)

    respond_to do |format|
      if logged_in?
        format.html # index.html.erb
      else
        store_location
        format.html { redirect_to :controller => 'login', :action => 'new' }
      end
#      format.xml  { render :xml => @action_types }
      format.json  { render :json => @action_types.to_json(ActionType.json_options)}
    end
  end

  # GET /action_types/1
  # GET /action_types/1.xml
  def show
    redirect_to :action => 'index'
    #@action_type = ActionType.find(params[:id])

    #respond_to do |format|
      #format.html # show.html.erb
      #format.xml  { render :xml => @action_type }
    #end
  end

  # GET /action_types/new
  # GET /action_types/new.xml
  def new
    @action_type = ActionType.new

    respond_to do |format|
      format.html # new.html.erb
#      format.xml  { render :xml => @action_type }
    end
  end

  # GET /action_types/1/edit
  def edit
    @action_type = ActionType.find(params[:id])
  end

  # POST /action_types
  # POST /action_types.xml
  def create
    @action_type = ActionType.new(params[:action_type])

    respond_to do |format|
      if @action_type.save
        flash[:notice] = 'ActionType was successfully created.'
        format.html { redirect_to(@action_type) }
#        format.xml  { render :xml => @action_type, :status => :created, :location => @action_type }
      else
        format.html { render :action => "new" }
#        format.xml  { render :xml => @action_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /action_types/1
  # PUT /action_types/1.xml
  def update
    @action_type = ActionType.find(params[:id])

    respond_to do |format|
      if @action_type.update_attributes(params[:action_type])
        flash[:notice] = 'ActionType was successfully updated.'
        format.html { redirect_to(@action_type) }
#        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
#        format.xml  { render :xml => @action_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /action_types/1
  # DELETE /action_types/1.xml
  def destroy
    @action_type = ActionType.find(params[:id])
    @action_type.destroy

    respond_to do |format|
      format.html { redirect_to(action_types_url) }
#      format.xml  { head :ok }
    end
  end
end
