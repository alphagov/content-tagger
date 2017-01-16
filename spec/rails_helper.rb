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
require 'govuk_sidekiq/testing'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/matchers/**/*.rb')].each { |f| require f }

PUBLISHING_API = "https://publishing-api.test.gov.uk".freeze

require 'capybara/rails'
require 'gds_api/test_helpers/publishing_api_v2'
require 'headless'
require 'database_cleaner'
require 'capybara/poltergeist'

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :rack_test
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::PublishingApiV2
  config.include FactoryGirl::Syntax::Methods

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  # Authenticate a test user for controllers.
  config.before(:each, type: :controller) do
    request.env['warden'] = double(
      authenticate!: true,
      authenticated?: true,
      user: User.new(permissions: ["signin"])
    )
  end

  config.before(:each) do
    User.create!
    DatabaseCleaner.start
    WebMock.reset!
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.around(:each, js: true) do |example|
    DatabaseCleaner.strategy = :truncation
    Capybara.javascript_driver = :poltergeist
    headless = Headless.new
    headless.start

    example.run

    headless.destroy
    Capybara.javascript_driver = :rack_test
    DatabaseCleaner.strategy = :transaction
  end
end

require 'govuk-content-schema-test-helpers/rspec_matchers'
RSpec.configuration.include GovukContentSchemaTestHelpers::RSpecMatchers
GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = 'publisher_v2'
  config.project_root = Rails.root
end
