require 'rails_helper'

RSpec.describe ProjectContentItemsController, type: :request do
  include TaxonomyHelper

  describe "#update" do
    before { create(:project, :with_content_item) }
    let(:project) { Project.first }
    let(:content_item) { project.content_items.first }

    it "responds with a 200 code when content item is updated successfully" do
      id = stub_content_id_lookup(content_item.base_path)
      stub_tag_content(id)

      patch(
        project_content_item_path(project, content_item),
        params: { project_content_item: { taxons: valid_taxon_uuid } }
      )

      expect(response.code).to eql "200"
    end

    it "responds with a 400 code when content item fails to update" do
      id = stub_content_id_lookup(content_item.base_path)
      stub_tag_content(id, success: false)

      patch(
        project_content_item_path(project, content_item),
        params: { project_content_item: { taxons: invalid_taxon_uuid } }
      )

      expect(response.code).to eql "400"
    end
  end

  def stub_content_id_lookup(base_path)
    id = SecureRandom.uuid
    stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
      .to_return(status: 200, body: { base_path => id }.to_json)
    id
  end
end
