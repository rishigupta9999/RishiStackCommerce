require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RishiStackCommerce
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

      if ENV['REDIS_URL']
        config.action_controller.perform_caching = true
        config.cache_store = :redis_store, { expires_in: 5.minutes }

        puts "Will perform caching"
      else
        config.action_controller.perform_caching = false
        config.cache_store = :null_store
      end
  end
end
