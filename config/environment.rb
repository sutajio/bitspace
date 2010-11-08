# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware #{RAILS_ROOT}/app/observers )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  config.gem 'aws-s3', :lib => 'aws/s3', :source => 'http://gemcutter.org'
  config.gem 'ruby-hmac', :lib => 'hmac', :source => 'http://gemcutter.org'
  config.gem 'ruby-mp3info', :lib => 'mp3info', :source => 'http://gemcutter.org'
  config.gem 'will_paginate', :source => 'http://gemcutter.org'
  config.gem 'bteitelb-paperclip', :lib => 'paperclip', :source => 'http://gemcutter.org'
  config.gem 'right_aws', :source => 'http://gemcutter.org'
  config.gem 'authlogic', :source => 'http://gemcutter.org'
  config.gem 'discogs', :source => 'http://gemcutter.org'
  config.gem 'scrobbler', :source => 'http://gemcutter.org'
  config.gem 'scrobbler2', :source => 'http://gemcutter.org'
  config.gem 'activemerchant', :lib => 'active_merchant', :source => 'http://gemcutter.org'
  config.gem 'MP4Info', :lib => 'mp4info', :source => 'http://gemcutter.org'
  config.gem 'ruby-ogginfo', :lib => 'ogginfo', :source => 'http://gemcutter.org'
  config.gem 'wmainfo-rb', :lib => 'wmainfo', :source => 'http://gemcutter.org'
  config.gem 'flacinfo-rb', :lib => 'flacinfo', :source => 'http://gemcutter.org'
  config.gem 'bluecloth', :source => 'http://gemcutter.org'
  config.gem 'rbrainz', :source => 'http://gemcutter.org'
  config.gem 'memcache-auth', :source => 'http://gemcutter.org'
  config.gem 'rfeedfinder', :source => 'http://gemcutter.org'
  config.gem 'feed-normalizer', :source => 'http://gemcutter.org'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :release_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.middleware.use 'JsonpMiddleware'
end