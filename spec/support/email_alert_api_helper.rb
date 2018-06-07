module EmailAlertApiHelper
  def stub_email_requests_for_show_page
    stub_request(:get, "https://email-alert-api.test.gov.uk/subscriber-lists")
      .to_return(body: [{ active_subscriptions_count: 24_601 }].to_json)
  end

  def stub_email_requests_for_show_page_with_error
    stub_request(:get, "https://email-alert-api.test.gov.uk/subscriber-lists")
      .to_raise(SocketError)
  end
end
