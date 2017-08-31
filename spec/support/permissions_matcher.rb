RSpec::Matchers.define :have_permission do |method|
  match do |permission_checker|
    permission_checker.send(method)
  end
end
