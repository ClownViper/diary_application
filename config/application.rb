require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "active_storage/engine"

Bundler.require(*Rails.groups)

module DiaryApp
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.assets.initialize_on_precompile = false

    # Set timezone to Japan Standard Time
    config.time_zone = "Asia/Tokyo"

    config.i18n.default_locale = :ja
    config.i18n.available_locales = [ :ja, :en ]

    # App configuration (name, subtitle, etc.) loaded from config/app.yml
    config.app = config_for(:app)
  end
end
