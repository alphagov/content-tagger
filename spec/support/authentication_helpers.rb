module AuthenticationControllerHelpers
  def login_as(user)
    request.env["warden"] = instance_double(
      Warden::Proxy,
      authenticate!: true,
      authenticated?: true,
      user:,
    )
  end

  def stub_user
    @stub_user ||= FactoryBot.create(:user, :gds_editor)
  end

  def login_as_stub_user
    login_as stub_user
  end
end

module AuthenticationFeatureHelpers
  def login_as(user)
    GDS::SSO.test_user = user
  end

  def stub_user
    @stub_user ||= FactoryBot.create(:user, :gds_editor)
  end

  def unreleased_feature_editor
    @unreleased_feature_editor ||= FactoryBot.create(:user, :unreleased_feature_editor)
  end

  def login_as_stub_user
    login_as stub_user
  end

  def login_as_unreleased_feature_editor
    login_as unreleased_feature_editor
  end
end

RSpec.configure do |config|
  config.include AuthenticationControllerHelpers, type: :controller
  config.before(:each, type: :controller) do
    login_as_stub_user
  end

  config.include AuthenticationFeatureHelpers, type: :feature
  config.before(:each, type: :feature) do
    login_as_stub_user
  end

  config.before(:example, type: :unreleased_feature) do
    login_as_unreleased_feature_editor
  end

  config.include AuthenticationFeatureHelpers, type: :request
  config.before(:each, type: :request) do
    login_as_stub_user
  end
end
