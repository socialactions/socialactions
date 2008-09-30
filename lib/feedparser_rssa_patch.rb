module FeedParser
  module FeedParserMixin

    alias_method :startup_orig, :startup
    def startup(baseuri=nil, baselang=nil, encoding='utf-8')
      rv = startup_orig(baseuri, baselang, encoding)
      @namespaces['http://socialactions.com/rssa/beta'] = 'rssa'
      @matchnamespaces['http://socialactions.com/rssa/beta'] = 'rssa'
      rv
    end

    def _start_rssa_goal(attrsD)
      @ingoal = true
      push('rssa:goal', true)
    end
    
    def _end_rssa_goal
      pop('rssa:goal')
      @ingoal = false
    end

    def _start_rssa_amount(attrsD)
      push('rssa:amount', true)
    end

    def _end_rssa_amount
      value = pop('rssa:amount')
      _save_goal('rssa_amount', value)
    end

    def _start_rssa_type(attrsD)
      push('rssa:type', true)
    end

    def _end_rssa_type
      value = pop('rssa:type')
      _save_goal('rssa_type', value)
    end

    def _start_rssa_completed(attrsD)
      push('rssa:completed', true)
    end

    def _end_rssa_completed
      value = pop('rssa:completed')
      _save_goal('rssa_completed', value)
    end


    def _start_rssa_numberofcontributors(attrsD)
      push('rssa:numberOfContributors', true)
    end

    def _end_rssa_numberofcontributors
      value = pop('rssa:numberOfContributors')
      _save_goal('rssa_numberofcontributors', value)
    end

    def _save_goal(key, value)
      context = getContext()
      context['rssa_goal'] ||= FeedParserDict.new
      context['rssa_goal'][key] = value
    end

    def _start_rssa_organization(attrsD)
      @inorganization = true
      push('rssa:organization', true)
    end
    
    def _end_rssa_organization
      pop('rssa:organization')
      @inorganization = false
    end

    def _start_rssa_platform(attrsD)
      @inplatform = true
      push('rssa:platform', true)
    end
    
    def _end_rssa_platform
      pop('rssa:platform')
      @inplatform = false
    end

    def _start_rssa_name(attrsD)
      push('rssa:name', true)
    end

    def _end_rssa_name
      value = pop('rssa:name')
      if @inorganization
        _save_organization('rssa_name', value)
      elsif @inplatform
        _save_platform('rssa_name', value)
      end
    end

    def _start_rssa_email(attrsD)
      push('rssa:email', true)
    end

    def _end_rssa_email
      value = pop('rssa:email')
      if @inorganization
        _save_organization('rssa_email', value)
      elsif @inplatform
        _save_platform('rssa_email', value)
      end
    end

    def _start_rssa_url(attrsD)
      push('rssa:url', true)
    end

    def _end_rssa_url
      value = pop('rssa:url')
      if @inorganization
        _save_organization('rssa_url', value)
      elsif @inplatform
        _save_platform('rssa_url', value)
      end
    end

    def _start_rssa_ein(attrsD)
      push('rssa:ein', true)
    end

    def _end_rssa_ein
      value = pop('rssa:ein')
      if @inorganization
        _save_organization('rssa_ein', value)
      elsif @inplatform
        _save_platform('rssa_ein', value)
      end
    end

    def _save_organization(key, value)
      context = getContext()
      context['rssa_organization'] ||= FeedParserDict.new
      context['rssa_organization'][key] = value
    end

    def _save_platform(key, value)
      context = getContext()
      context['rssa_platform'] ||= FeedParserDict.new
      context['rssa_platform'][key] = value
    end
  end
end
