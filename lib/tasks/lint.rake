desc "Run govuk-lint on files changed since origin/master"
task "lint" do
  system "govuk-lint-ruby --diff"
end
