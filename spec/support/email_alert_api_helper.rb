require "gds_api/test_helpers/email_alert_api"

module EmailAlertApiHelper
  include GdsApi::TestHelpers::EmailAlertApi

  def stub_email_requests_for_show_page
    email_alert_api_has_subscriber_list(active_subscriptions_count: 24_601)
  end

  def stub_email_requests_for_show_page_with_error
    stub_request(:get, build_subscriber_lists_url).to_raise(SocketError)
  end
end
