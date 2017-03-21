namespace :taxonomy do
  desc <<-DESC
    Register a content item representing the email-alert-frontend endpoint that
    handles taxonomy email alert subscriptions
  DESC
  task register_email_signup_page: :environment do
    def base_path
      '/taxonomy-email-signup'
    end

    def routes
      [
        { path: base_path, type: "exact" },
        { path: "#{base_path}/confirm", type: "exact" },
      ]
    end

    # The base_path and routes specified here are the only important values -
    # we want to ensure the specified path is reserved correctly via the
    # publishing-api. All other fields are populated with nominal values,
    # particularly the details hash which needs to satisfy the schema
    # definition for an email_alert_signup.
    email_signup_page = {
      base_path: base_path,
      document_type: 'email_alert_signup',
      schema_name: 'email_alert_signup',
      title: 'Get email alerts',
      description: '',
      locale: 'en',
      need_ids: [],
      public_updated_at: DateTime.now.iso8601,
      publishing_app: 'content-tagger',
      rendering_app: 'email-alert-frontend',
      routes: routes,
      details: {
        summary: '',
        subscriber_list: { 'taxons' => [] },
      },
    }

    content_id = 'e3bf851b-5df7-441b-8813-f0ec849da35f'

    Services.publishing_api.put_content(content_id, email_signup_page)
    Services.publishing_api.publish(content_id, 'major')
  end
end
