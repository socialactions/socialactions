class PingController < ApplicationController
  protect_from_forgery :except => 'index'

  def index
    #warn params[:methodCall][:methodName]
    if params[:methodCall][:methodName] == 'weblogUpdates.ping'
      url = params[:methodCall][:params][:param][1][:value]
      @action_source = ActionSource.find_by_url(url)
      @action_source.update_attribute(:needs_updating, true)
      #warn url
    end
    #warn params.inspect

    render :layout => false
  end
end
