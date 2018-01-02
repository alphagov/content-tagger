require 'rails_helper'

RSpec.describe TaxonsController, type: :controller do
  include PublishingApiHelper
  include ContentItemHelper

  describe "#index" do
    it "renders index" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }

      publishing_api_has_taxons([taxon])

      get :index

      expect(response.code).to eql "200"
    end
  end

  describe "#drafts" do
    it "renders drafts" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }

      publishing_api_has_draft_taxons([taxon])

      get :drafts

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

      get :show, params: { id: "does-not-exist" }

      expect(response.code).to eql "404"
    end
  end

  describe "#destroy" do
    it "sends a request to Publishing API to mark the taxon as 'redirect'" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      taxon_redirected_to = { title: "bar", base_path: "/bar", content_id: SecureRandom.uuid }
      foo_content_id = taxon[:content_id]
      bar_content_id = taxon_redirected_to[:content_id]

      # We'll redirect to the show page
      stub_taxon_show_page(foo_content_id)

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{bar_content_id}")
        .to_return(status: 200, body: taxon_redirected_to.to_json, headers: {})

      stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
        .with(body: "{\"type\":\"redirect\",\"alternative_path\":\"#{taxon_redirected_to[:base_path]}\"}")
        .to_return(status: 200, body: "", headers: {})

      publishing_api_has_taxons([taxon])

      delete :destroy, params: { id: foo_content_id, taxon: { redirect_to: bar_content_id } }
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
    end

    it "does not send a request to Publishing API if a taxon to redirect to is not provided" do
      taxon = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      foo_content_id = taxon[:content_id]

      # We'll redirect to the show page
      stub_taxon_show_page(foo_content_id)

      publishing_api_has_taxons([taxon])

      delete :destroy, params: { id: foo_content_id, taxon: { redirect_to: "" } }
      expect(WebMock).to_not have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{foo_content_id}/unpublish")
    end

    it "prevents deletion of the homepage" do
      delete :destroy, params: { id: GovukTaxonomy::ROOT_CONTENT_ID }

      expect(WebMock).to_not have_requested(:any, /publishing-api/)
      expect(flash[:danger]).to eq "You cannot delete the homepage"
      expect(request).to redirect_to taxon_path(GovukTaxonomy::ROOT_CONTENT_ID)
    end
  end

  describe '#bulk_publish' do
    it 'bulk publishes content' do
      expect(Taxonomy::BulkUpdateTaxon).to receive(:call).with('123')
      post :bulk_publish, params: { taxon_id: 123 }
      expect(response).to redirect_to(taxon_path(123))
    end
  end

  describe "#publish" do
    it 'responds with a specific error when the base path is already used' do
      taxon = build(:taxon, publication_state: "unpublished", content_id: SecureRandom.uuid)
      stub_publishing_api_publish(taxon.content_id, {}, status: 422)
      payload = Taxonomy::BuildTaxonPayload.call(taxon: taxon)
      publishing_api_has_item(payload.merge(content_id: taxon.content_id))
      publishing_api_has_links(content_id: taxon.content_id)
      publishing_api_has_lookups(taxon.base_path => SecureRandom.uuid)

      post :publish, params: { taxon_id: taxon.content_id }

      expect(flash.now[:danger]).to match(/<a href="(.+)">taxon<\/a> with this slug already exists/)
    end
  end

  describe '#confirm_bulk_publish' do
    it 'renders confirm bulk publish' do
      expect(Taxonomy::BuildTaxon).to receive(:call).with(content_id: '123').and_return FactoryGirl.build(:taxon)
      get :confirm_bulk_publish, params: { taxon_id: 123 }
      expect(response.code).to eql "200"
    end
  end

  describe "#restore" do
    it "sends a request to Publishing API to mark the taxon as 'draft'" do
      taxon = build(:taxon, publication_state: "unpublished")

      Timecop.freeze do
        payload = Taxonomy::BuildTaxonPayload.call(taxon: taxon)
        links = {
          links: {
            parent_taxons: ['guid'],
            associated_taxons: ['1234'],
          }
        }

        publishing_api_has_item(payload.merge(content_id: taxon.content_id))
        publishing_api_has_links(links.merge(content_id: taxon.content_id))
        stub_publishing_api_put_content(taxon.content_id, payload)
        stub_publishing_api_patch_links(taxon.content_id, links.to_json)

        post :restore, params: { taxon_id: taxon.content_id }
      end

      expect(WebMock).to have_requested(:put, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}")
      expect(WebMock).to have_requested(:patch, "https://publishing-api.test.gov.uk/v2/links/#{taxon.content_id}")
      expect(WebMock).to_not have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}/publish")
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

      delete :discard_draft, params: { taxon_id: taxon.content_id }
      expect(WebMock).to have_requested(:post, "https://publishing-api.test.gov.uk/v2/content/#{taxon.content_id}/discard-draft")
    end
  end

  def stub_taxon_show_page(content_id)
    stub_requests_for_show_page(
      content_item_with_details("Foo", other_fields: { content_id: content_id, document_type: "taxon" })
    )
  end
end
