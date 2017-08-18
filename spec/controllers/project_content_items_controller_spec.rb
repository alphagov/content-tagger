require 'rails_helper'

RSpec.describe ProjectContentItemsController, type: :request do
  include TaxonomyHelper

  describe "#update" do
    before { create(:project, :with_content_item) }
    let(:project) { Project.first }
    let(:content_item) { project.content_items.first }

    it "responds with a 200 code when content item is updated successfully" do
      stub_tag_content(content_item.content_id)

      patch(
        project_content_item_path(project, content_item),
        params: { project_content_item: { taxons: valid_taxon_uuid } }
      )

      expect(response.code).to eql "200"
    end

    it "responds with a 400 code when content item fails to update" do
      stub_tag_content(content_item.content_id, success: false)

      patch(
        project_content_item_path(project, content_item),
        params: { project_content_item: { taxons: invalid_taxon_uuid } }
      )

      expect(response.code).to eql "400"
    end
  end
end
