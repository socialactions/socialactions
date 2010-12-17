require 'base62'

class Shorturl::Redirect < ActiveRecord::Base
  attr_accessor :slug
  
  attr_accessor :logs
  attr_accessor :unique_referrers
  
  validates_uniqueness_of :cookie, :scope => [:url], :message => " has already been taken for this url"
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
                      :message => " is invalid, check format"
  
  def slug
    @slug ||= Base62.encode(id)
  end
  
  def logs
    @logs ||= Shorturl::Log.find_all_by_redirect_id(id)
  end
  
  def unique_referrers
    @unique_referrers ||= Shorturl::Log.unique_referrers_for_logs(logs)
  end
  
  def all_for_this_url
    self.find_all_by_url(url)
  end
  
  def all_for_this_cookie
    self.find_all_by_cookie(cookie)
  end
  
  def self.find_by_slug(slug)
    find_by_id(Base62.decode(slug))
  end
  
  def self.find_or_create_by_cookie_and_url(params)
    if self.exists?(:cookie => params[:cookie], :url => params[:url])
      return find(:first, :conditions => { :cookie => params[:cookie], :url => params[:url] })
    end
    self.new(:cookie => params[:cookie], :url => params[:url])
  end
  
  def self.find_by_cookie_and_url(params)
    return find(:first, :conditions => { :cookie => params[:cookie], :url => params[:url] })
  end
  
end
