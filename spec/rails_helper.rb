if ENV['USE_COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] = 'test'
ENV['GOVUK_APP_DOMAIN'] = 'test.gov.uk'

require File.expand_path('../../config/environment', __FILE__)
require 'spec_helper'
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require 'capybara/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Authenticate a test user for controllers.
  config.before(:each, type: :controller) do
    request.env['warden'] = double(
      authenticate!: true,
      authenticated?: true,
      user: User.new(permissions: ["signin"])
    )
  end
end
