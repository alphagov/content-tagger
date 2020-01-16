source "https://rubygems.org"

gem "rails", "6.0.2.1"

gem "bootstrap-kaminari-views", "~> 0.0.5"
gem "govuk_app_config", "~> 2.0"
gem "hashdiff", "~> 1.0.0"
gem "jquery-ui-rails", "6.0.1"
gem "kaminari", "~> 1.1"
gem "pg"
gem "rack-proxy"
gem "sass-rails", "~> 6.0"
gem "select2-rails", "~> 3.5.9"
gem "simple_form", "~> 5.0"
gem "uglifier", "~> 4.2"

# GDS managed dependencies
gem "gds-api-adapters", "~> 63.3"
gem "gds-sso", "~> 14.2"
gem "govuk_admin_template", "~> 6.7"
gem "govuk_sidekiq", "~> 3.0"
gem "govuk_taxonomy_helpers", "~> 1.0.0"
gem "plek", "~> 3.0"

group :development, :test do
  gem "awesome_print"
  gem "factory_bot_rails"
  gem "govuk-content-schema-test-helpers"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0.0.beta4"
  gem "rubocop-govuk"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
end

group :development do
  gem "better_errors"
  gem "web-console"
end

group :test do
  gem "database_cleaner"
  gem "govuk_test"
  gem "timecop"
  gem "webmock"
end
