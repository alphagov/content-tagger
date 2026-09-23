desc "Run all linters"
task lint: :environment do
  sh "bundle exec erb_lint --lint-all"
  sh "bundle exec rubocop"
  sh "yarn run lint"
end
