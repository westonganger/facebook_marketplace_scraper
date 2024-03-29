require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "fb_scraper"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.eager_load = true ### to catch more bugs in development/test environments

    if Rails.env.development?
      config.log_level = (ENV["FB_SCRAPER_LOG_LEVEL"].presence || :debug)
    end
  end
end
