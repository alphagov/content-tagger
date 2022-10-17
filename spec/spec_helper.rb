require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] = "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../config/environment", __dir__)
require "spec_helper"
require "rspec/rails"
require "govuk_sidekiq/testing"
require "webmock/rspec"
require "capybara/rails"
require "gds_api/test_helpers/publishing_api"
require "database_cleaner"
require "govuk_test"
require "govuk_schemas/rspec_matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("spec/matchers/**/*.rb")].sort.each { |f| require f }

PUBLISHING_API = "https://publishing-api.test.gov.uk".freeze

WebMock.disable_net_connect!(allow_localhost: true)

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :rack_test
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus

  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  config.default_formatter = "doc"

  config.order = :random

  Kernel.srand config.seed

  config.include GdsApi::TestHelpers::PublishingApi
  config.include FactoryBot::Syntax::Methods
  config.include GovukSchemas::RSpecMatchers

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
