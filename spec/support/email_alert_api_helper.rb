require "gds_api/test_helpers/email_alert_api"

module EmailAlertApiHelper
  include GdsApi::TestHelpers::EmailAlertApi

  def stub_email_requests_for_show_page
    stub_request(:get, build_subscriber_lists_url)
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        body: get_subscriber_list_response(active_subscriptions_count: 24_601).to_json,
      )
  end

  def stub_email_requests_for_show_page_with_error
    stub_request(:get, build_subscriber_lists_url)
      .with(query: hash_including({}))
      .to_raise(SocketError)
  end
end
