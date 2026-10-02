require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OctochangelogOnRailsPro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # rack-proxy 1.x requires a configured backend rather than deriving one from Host.
    initializer "octochangelog.shakapacker_proxy", after: "shakapacker.proxy" do |app|
      if Shakapacker.config.dev_server.present?
        dev_server = Shakapacker.dev_server
        app.middleware.swap Shakapacker::DevServerProxy, Shakapacker::DevServerProxy,
          ssl_verify_none: true, backend: "#{dev_server.protocol}://#{dev_server.host_with_port}"
      end
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
