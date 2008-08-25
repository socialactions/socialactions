class PingController < ApplicationController
  protect_from_forgery :except => 'index'

  def index
    #warn params[:methodCall][:methodName]
    if params[:methodCall][:methodName] == 'weblogUpdates.ping'
      url = params[:methodCall][:params][:param][1][:value]
      @feed = Feed.find_by_url(url)
      @feed.update_attribute(:needs_updating, true)
      #warn url
    end
    #warn params.inspect
  end
end
