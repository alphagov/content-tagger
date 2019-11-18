desc "Run rubocop on all files"
task "lint" do
  system "rubocop app lib spec test Gemfile"
end
