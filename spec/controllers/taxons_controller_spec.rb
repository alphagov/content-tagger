require 'rails_helper'

RSpec.describe TaxonsController, type: :controller do
  describe "#index" do
    it "renders index" do
      taxon_1 = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      taxon_2 = { title: "bar", base_path: "/bar", content_id: SecureRandom.uuid }
      taxon_3 = { title: "aha", base_path: "/aha", content_id: SecureRandom.uuid }

      publishing_api_has_content([taxon_1, taxon_2, taxon_3], document_type: "taxon")

      get :index

      expect(response.code).to eql "200"
    end
  end

  describe "#destroy" do
    it "sends a request to Publishing API to mark the taxon as 'gone'" do
      taxon_1 = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      taxon_2 = { title: "bar", base_path: "/bar", content_id: SecureRandom.uuid }
      foo_content_id = taxon_1[:content_id]

      stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
        .with(body: "{\"type\":\"gone\"}")
        .to_return(status: 200, body: "", headers: {})

      publishing_api_has_content([taxon_1, taxon_2], document_type: "taxon")

      delete :destroy, id: foo_content_id
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
    end
  end
end
