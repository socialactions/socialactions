require 'sunspot'

module Sunspot
  module Search
    class AbstractSearch
      
      # Return the entire solr result, to provide access to debug output
      def solr_result
        @solr_result
      end
    end
  end
end

