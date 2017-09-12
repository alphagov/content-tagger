require 'rails_helper'

RSpec.describe RootTaxonsController, type: :controller do
  describe "#index" do
    it "gets root links" do
      publishing_api_has_links("content_id" => GovukTaxonomy::ROOT_CONTENT_ID,
                               "links" => { "root_taxons" => [] })

      get :index

      expect(response.code).to eql "200"
    end
  end

  describe "#update_all" do
    it "redirects to the edit all taxons page" do
      stub_any_publishing_api_patch_links
      put :update_all, params: { 'root_taxons_form' => { root_taxons: ["", "ID-1", "ID-2"] } }

      expect(response).to redirect_to(edit_all_root_taxons_path)
    end
  end
end
