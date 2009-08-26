module FeedParser
  module FeedParserMixin

    alias_method :startup_orig, :startup
    def startup(baseuri=nil, baselang=nil, encoding='utf-8')
      rv = startup_orig(baseuri, baselang, encoding)
      @namespaces['http://socialactions.com/oa/beta'] = 'oa'
      @matchnamespaces['http://socialactions.com/oa/beta'] = 'oa'
      rv
    end

    def _start_oa_goal(attrsD)
      @ingoal = true
      push('oa:goal', true)
    end
    
    def _end_oa_goal
      pop('oa:goal')
      @ingoal = false
    end

    def _start_oa_amount(attrsD)
      push('oa:amount', true)
    end

    def _end_oa_amount
      value = pop('oa:amount')
      _save_goal('oa_amount', value)
    end

    def _start_oa_type(attrsD)
      push('oa:type', true)
    end

    def _end_oa_type
      value = pop('oa:type')
      _save_goal('oa_type', value)
    end

    def _start_oa_completed(attrsD)
      push('oa:completed', true)
    end

    def _end_oa_completed
      value = pop('oa:completed')
      _save_goal('oa_completed', value)
    end


    def _start_oa_numberofcontributors(attrsD)
      push('oa:numberOfContributors', true)
    end

    def _end_oa_numberofcontributors
      value = pop('oa:numberOfContributors')
      _save_goal('oa_numberofcontributors', value)
    end

    def _save_goal(key, value)
      context = getContext()
      context['oa_goal'] ||= FeedParserDict.new
      context['oa_goal'][key] = value
    end

    def _start_oa_organization(attrsD)
      @inorganization = true
      push('oa:organization', true)
    end
    
    def _end_oa_organization
      pop('oa:organization')
      @inorganization = false
    end

    def _start_oa_platform(attrsD)
      @inplatform = true
      push('oa:platform', true)
    end
    
    def _end_oa_platform
      pop('oa:platform')
      @inplatform = false
    end

    def _start_oa_location(attrsD)
      @inlocation = true
      push('oa:location', true)
    end
    
    def _end_oa_location
      pop('oa:location')
      @inlocation = false
    end

    def _start_oa_name(attrsD)
      push('oa:name', true)
    end

    def _end_oa_name
      value = pop('oa:name')
      if @inorganization
        _save_organization('oa_name', value)
      elsif @inplatform
        _save_platform('oa_name', value)
      end
    end

    def _start_oa_email(attrsD)
      push('oa:email', true)
    end

    def _end_oa_email
      value = pop('oa:email')
      if @inorganization
        _save_organization('oa_email', value)
      elsif @inplatform
        _save_platform('oa_email', value)
      end
    end

    def _start_oa_url(attrsD)
      push('oa:url', true)
    end

    def _end_oa_url
      value = pop('oa:url')
      if @inorganization
        _save_organization('oa_url', value)
      elsif @inplatform
        _save_platform('oa_url', value)
      end
    end

    def _start_oa_ein(attrsD)
      push('oa:ein', true)
    end

    def _end_oa_ein
      value = pop('oa:ein')
      if @inorganization
        _save_organization('oa_ein', value)
      elsif @inplatform
        _save_platform('oa_ein', value)
      end
    end
    
    def _start_oa_city(attrsD)
      push('oa:city',true)
    end
    
    def _end_oa_city
      value = pop('oa:city')
      if @inlocation
        _save_location('oa_city',value)
      end
    end
    
    def _start_oa_country(attrsD)
      push('oa:country',true)
    end
    
    def _end_oa_country
      value = pop('oa:country')
      if @inlocation
        _save_location('oa_country',value)
      end
    end
    
    def _start_oa_state(attrsD)
      push('oa:state',true)
    end
    
    def _end_oa_state
      value = pop('oa:state')
      if @inlocation
        _save_location('oa_state',value)
      end
    end
    
    def _start_oa_postalcode(attrsD)
      push('oa:postalcode',true)
    end
    
    def _end_oa_postalcode
      value = pop('oa:postalcode')
      if @inlocation
        _save_location('oa_postalcode',value)
      end
    end

    def _save_organization(key, value)
      context = getContext()
      context['oa_organization'] ||= FeedParserDict.new
      context['oa_organization'][key] = value
    end

    def _save_platform(key, value)
      context = getContext()
      context['oa_platform'] ||= FeedParserDict.new
      context['oa_platform'][key] = value
    end
    
    def _save_location(key, value)
      context = getContext()
      context['oa_location'] ||= FeedParserDict.new
      context['oa_location'][key] = value
    end
  end
end
