namespace :taxonomy do
  desc <<-DESC
    Register a content item representing the email-alert-frontend endpoint that
    handles taxonomy email alert subscriptions
  DESC
  task register_email_signup_page: :environment do
    signup_page = Taxonomy::EmailSignupPage.new

    Services.publishing_api.put_content(signup_page.content_id, signup_page.payload)
    Services.publishing_api.publish(signup_page.content_id)
  end
end
