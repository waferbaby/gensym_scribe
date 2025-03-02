require_relative "boot"

require "rails"

require "action_view/railtie"
require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"

Bundler.require(*Rails.groups)

module GensymScribe
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
    config.hosts << "99dd-124-168-216-50.ngrok-free.app"
  end
end
