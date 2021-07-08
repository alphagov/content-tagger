GovukAdminTemplate.configure do |c|
  c.app_title = "Content Tagger"
  c.show_signout = true
  c.show_flash = true
end

GovukAdminTemplate.environment_label = ENV.fetch("GOVUK_ENVIRONMENT_NAME", "development").titleize
GovukAdminTemplate.environment_style = ENV["GOVUK_ENVIRONMENT_NAME"] == "production" ? "production" : "preview"
