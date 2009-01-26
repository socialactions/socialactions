class Shorturl::Log < ActiveRecord::Base
 
  attr_accessor :slug
  
  def slug
    @slug ||= Base62.encode(redirect_id)
  end
  
  def field_names
    ['slug','url','cookie','referrer','date']
  end
  
  def field_values
    r = Shorturl::Redirect.find_by_id(redirect_id)
    [slug,r.url,r.cookie,referrer,created_at]
  end
    
  # Various ways to retrieve logs  
  
  def self.find_all_by_slug(slug)
    find_all_by_redirect_id(Base62.decode(slug))
  end
  
  def self.find_all_by_cookie(cookie)
    logs_for_redirects(Shorturl::Redirect.find_all_by_cookie(cookie))
  end
  
  def self.find_all_by_url(url)
    logs_for_redirects(Shorturl::Redirect.find_all_by_url(url))
  end
  
  def self.logs_for_redirects(redirects)
    logs = []
    if !redirects.empty?
      redirects.each do |redirect|
        logs = logs + find_all_by_redirect_id(redirect.id)
      end
    end
    logs
  end
  
  # Various ways to retrieve unique referrers
  
  def self.unique_referrers_by_slug(slug)
    unique_referrers_by_redirect_id(Base62.decode(slug))
  end
  
  def self.unique_referrers_by_redirect_id(redirect_id)
    unique_referrers_for_logs(find_all_by_redirect_id(redirect_id))
  end
    
  def self.unique_referrers_for_logs(logs)
    referrers = []
    if !logs.empty?
      logs.each do |log|
        referrers << log.referrer unless log.referrer.nil?
      end
    end
    referrers.uniq
  end
  
end
