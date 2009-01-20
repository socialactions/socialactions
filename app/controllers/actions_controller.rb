class ActionsController < ApplicationController
  
  def index
    begin
      @search = Search.new(search_params)
      @actions = @search.results(params[:page])
      respond_to do |format|
        format.html { @actions.excerpt }
        format.json  { render :json => @actions.results.to_json(Action.json_options) }
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
  
  def show
    @action = Action.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false}
      format.xml
    end    
  end

end

