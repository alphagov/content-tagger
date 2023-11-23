source "https://rubygems.org"

gem "rails", "7.1.2"

gem "bootsnap", require: false
gem "bootstrap-kaminari-views"
gem "govuk_app_config"
gem "hashdiff"
gem "jquery-ui-rails"
gem "kaminari"
gem "pg"
gem "prometheus-client"
gem "rack-proxy"
gem "sassc-rails"
gem "select2-rails", "< 4" # There are unresolved visual and HTML changes with select2-rails 4
gem "sentry-sidekiq"
gem "simple_form"
gem "sprockets-rails"
gem "uglifier"

gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_admin_template"
gem "govuk_sidekiq"
gem "plek"

group :development, :test do
  gem "awesome_print"
  gem "factory_bot_rails"
  gem "govuk_schemas"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
  gem "simplecov", require: false
end

group :development do
  gem "better_errors"
  gem "web-console"
end

group :test do
  gem "fakefs", require: "fakefs/safe"
  gem "govuk_test"
  gem "webmock"
end
