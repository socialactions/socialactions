class FeedsController < ApplicationController
  def ping
    @feed = Feed.find_by_url(params[:url]) or 
      return render(:text => "We are not currently aggregating url: \"#{params[:url]}\"", :status => 400)
    @feed.update_attribute(:needs_updating, true)

    render :text => "Thanks for the ping."
  end
end
