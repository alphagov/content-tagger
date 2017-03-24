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

  describe "#trash" do
    it "renders trash" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }

      publishing_api_has_deleted_taxons([taxon])

      get :trash

      expect(response.code).to eql "200"
    end
  end

  describe "#show" do
    it "renders 404 for unknown taxons" do
      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/does-not-exist")
        .to_return(status: 404)

      get :show, id: "does-not-exist"

      expect(response.code).to eql "404"
    end
  end

  describe "#destroy" do
    it "sends a request to Publishing API to mark the taxon as 'gone'" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      foo_content_id = taxon[:content_id]

      # We'll redirect to the show page
      stub_taxon_show_page(foo_content_id)

      stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
        .with(body: "{\"type\":\"gone\"}")
        .to_return(status: 200, body: "", headers: {})

      publishing_api_has_taxons([taxon])

      delete :destroy, id: foo_content_id
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
    end
  end

  describe "#discard_draft" do
    it "sends a request to Publishing API to delete the draft taxon" do
      taxon = build(:taxon, publication_state: "draft")
      publishing_api_has_taxons([taxon])

      stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}/discard-draft")
        .to_return(status: 200, body: "", headers: {})

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}")
        .to_return(status: 200, body: { content_id: "ID-1", base_path: "/foo", title: "Foo", publication_state: "draft", details: { internal_name: "foo" } }.to_json, headers: {})

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/#{taxon.content_id}")
        .to_return(status: 200, body: {}.to_json, headers: {})

      delete :discard_draft, taxon_id: taxon.content_id
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}/discard-draft")
    end
  end
end
