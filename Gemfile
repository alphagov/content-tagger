source 'https://rubygems.org'

gem 'rails', '5.0.2'

gem 'bootstrap-kaminari-views', '~> 0.0.5'
gem 'chartkick'
gem 'jquery-ui-rails', '6.0.1'
gem 'kaminari', '~> 0.17'
gem 'logstasher', '~> 1.2'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'select2-rails', '~> 3.5.9'
gem 'simple_form', '~> 3.2', '>= 3.2.1'
gem 'uglifier', '~> 3.2'
gem 'unicorn', '~> 5.0.0'

# GDS managed dependencies
gem 'airbrake', github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'gds-api-adapters', '~> 41.5'
gem 'gds-sso', '~> 13.2'
gem 'govuk_admin_template', '~> 5.0'
gem 'govuk_sidekiq', '~> 1.0'
gem 'govuk_taxonomy_helpers', '~> 0.1.0'
gem 'plek', '~> 2.0'

group :development, :test do
  gem 'awesome_print'
  gem 'factory_girl_rails'
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

group :development do
  gem 'better_errors'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'headless'
  gem 'poltergeist'
  gem 'webmock'
end
