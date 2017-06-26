require 'rails_helper'

RSpec.describe RootTaxonsController, type: :controller do
  describe "#index" do
    it "gets root links" do
      publishing_api_has_links("content_id" => RootTaxonsForm::HOMEPAGE_CONTENT_ID,
                               "links" => { "root_taxons" => [] })

      get :index

      expect(response.code).to eql "200"
    end
  end

  describe "#update" do
    it "redirects to the taxons index page" do
      stub_any_publishing_api_patch_links
      put :update, params: { 'root_taxons_form' => { root_taxons: ["", "ID-1", "ID-2"] } }

      expect(response).to redirect_to(taxons_path)
    end
  end
end
