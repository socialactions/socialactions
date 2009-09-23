require 'digest/md5'

class ApiKey < ActiveRecord::Base
  
  validates_presence_of :host_domain
  validates_uniqueness_of :key
  before_save :create_key
  
  def validate_host(env)
    if !env["HTTP_REFERER"].nil? && env["HTTP_REFERER"].match(self.host_domain) != nil
      return true
    elsif env["REMOTE_HOST"] == self.host_domain
      return true
    elsif env["REMOTE_ADDR"] == self.host_domain
      return true
    end
    return false
  end
  
  def create_key
    self.key = Digest::MD5.hexdigest("#{self.name}#{self.host_domain}")
  end
  
end
