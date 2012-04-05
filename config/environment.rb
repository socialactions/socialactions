# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  config.gem 'mysql'
  config.gem 'thin'
  config.gem 'json', :version => '1.4.6'
  config.gem 'haml', :version => '3.0.23'
  config.gem 'fastercsv', :version => '1.5.3'
  config.gem 'simple-rss', :version => '1.2.3'
  config.gem 'rfeedparser', :version => '0.9.951'
  # Not using latest libxml-ruby, rfeedparse 0.9.951 seems to have issues with it
  #
  # gems/rfeedparser-0.9.951/lib/rfeedparser/libxml_parser.rb:14: warning: Passing no parameters to XML::SaxParser.new is deprecated.  Pass an instance of XML::Parser::Context instead.
  # XML::SaxParser#string is deprecated.  Use XML::SaxParser.string instead
  # Also, malloc errors were occurring
  #
  #config.gem 'libxml-ruby', :version => '1.1.4', :lib => 'libxml'
  # config.gem 'libxml-ruby', :version => '0.8.3', :lib => 'libxml'
  config.gem 'libxml-ruby', :lib => 'libxml'
  config.gem 'soap4r', :version => '1.5.8', :lib => 'soap/soap.rb'
  config.gem 'sunspot_rails', :lib => 'sunspot/rails', :version => '1.1.0'
  config.gem 'api_cache', :version => '0.2.0'
  config.gem 'moneta', :version => '0.6.0'

  # nokogiri is a prereq for sunspot_rails sunspot-installer
  # We won't use it, or care about the version...
  # http://groups.google.com/group/ruby-sunspot/msg/16aa28f4d52e21da
  config.gem 'nokogiri'

  config.gem 'oink'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de


  require 'hodel_3000_compliant_logger'
  config.logger = Hodel3000CompliantLogger.new(config.log_path)


  config.after_initialize do
    #require 'moneta/memcache'
    #APICache.store = Moneta::Memcache.new(:server => "localhost")
    require 'moneta/basic_file'
    APICache.store = Moneta::BasicFile.new(:path => File.join(RAILS_ROOT, "tmp", "moneta"))
  end

  API_CACHE_OPTIONS = {
    :cache => 86400, # 1 day
    :period => 1,
    :timeout => 10
  }



end
