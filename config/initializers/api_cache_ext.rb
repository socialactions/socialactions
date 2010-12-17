require 'api_cache.rb'

class APICache

  class << self

    # Extend to allow retries when API period has not been met
    alias_method :orig_get, :get
   end

  def self.get(key, options = {}, &block)
    # Declare default that's also in the gem, so we have access to it here
    options[:period] ||= 60

    tries = 3 # Number of times to try if there's some sort of error

    retryable = (options[:non_blocking] || nil) ? false : true

    begin
      return self.orig_get key, options, &block
    rescue APICache::CannotFetch
      raise unless retryable
      p "Waiting for period to expire to retry api call..."
      retryable = false
      sleep options[:period]
      retry
    rescue RuntimeError
      raise if tries == 0
      p "API request failure, waiting to retry api call..."
      tries -= 1
      sleep 5 # Sleep for a bit before trying again
      retry
    end
  end

end
