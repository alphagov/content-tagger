desc "Run rubocop on all files"
task lint: :environment do
  system "rubocop app lib spec test Gemfile"
end
