require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module ContentTagger
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configure blacklisted tag types by publishing app
    config.blacklisted_tag_types = config_for(:blacklisted_tag_types)

    config.active_record.belongs_to_required_by_default = false
  end
end
