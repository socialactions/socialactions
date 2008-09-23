class Redirect < ActiveResource::Base
  # See config/environments for self.site value and @off value
  # self.site = "http://localhost/"
  @off = true
  
  def self.off=(bool)
      @off = bool
  end
  
  def self.off?
    @off
  end
end