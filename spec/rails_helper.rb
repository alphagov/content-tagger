if ENV["USE_COVERAGE"]
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start "rails"
end

ENV["RAILS_ENV"] = "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../config/environment", __dir__)
require "spec_helper"
require "rspec/rails"
require "govuk_sidekiq/testing"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("spec/matchers/**/*.rb")].sort.each { |f| require f }

PUBLISHING_API = "https://publishing-api.test.gov.uk".freeze

require "capybara/rails"
require "gds_api/test_helpers/publishing_api"
require "database_cleaner"
require "govuk_test"

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :rack_test
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::PublishingApi
  config.include FactoryBot::Syntax::Methods

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  Rails.application.load_tasks

  config.before(:each) do
    User.create!(permissions: ["signin", "GDS Editor"])
    DatabaseCleaner.start
    WebMock.reset!
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.around(:each, js: true) do |example|
    DatabaseCleaner.strategy = :truncation
    GovukTest.configure

    example.run

    Capybara.javascript_driver = :rack_test
    DatabaseCleaner.strategy = :transaction
  end
end

require "govuk-content-schema-test-helpers/rspec_matchers"
RSpec.configuration.include GovukContentSchemaTestHelpers::RSpecMatchers
GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = "publisher_v2"
  config.project_root = Rails.root
end
