require 'webmock/rspec'

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

  config.default_formatter = 'doc'

  config.order = :random

  Kernel.srand config.seed

  config.before :suite do
    User.create!
  end

  config.before(:each) do
    WebMock.reset!
  end

  config.after :suite do
    unless ENV["SKIP_LINT_IN_SPECS"]
      require "govuk/lint/cli"
      Govuk::Lint::CLI.new.run([])
    end
  end
end
