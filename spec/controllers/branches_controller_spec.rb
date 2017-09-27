require 'rails_helper'

RSpec.describe BranchesController, type: :controller do
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
      put :update_all, params: { 'branches_form' => { branches: ["", "ID-1", "ID-2"] } }

      expect(response).to redirect_to(edit_all_branches_path)
    end
  end
end
