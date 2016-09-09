require 'rails_helper'

RSpec.describe TaxonsController, type: :controller do
  include PublishingApiHelper

  describe "#index" do
    it "renders index" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }

      publishing_api_has_taxons([taxon])

      get :index

      expect(response.code).to eql "200"
    end
  end

  describe "#destroy" do
    it "sends a request to Publishing API to mark the taxon as 'gone'" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      foo_content_id = taxon[:content_id]

      stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
        .with(body: "{\"type\":\"gone\"}")
        .to_return(status: 200, body: "", headers: {})

      publishing_api_has_taxons([taxon])

      delete :destroy, id: foo_content_id
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
    end
  end
end
