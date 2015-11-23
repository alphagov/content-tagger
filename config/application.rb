require File.expand_path('../boot', __FILE__)

require "rails"

require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module ContentTagger
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true

    config.action_view.default_form_builder = GenericFormBuilder
    config.action_view.field_error_proc = proc {|html_tag, _| html_tag }
  end
end
