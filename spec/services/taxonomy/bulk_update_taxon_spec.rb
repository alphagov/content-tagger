require "rails_helper"

RSpec.describe Taxonomy::BulkPublishTaxon do
  before do
    item = GovukTaxonomyHelpers::LinkedContentItem.new(title: "item1", base_path: "/item1", content_id: "id1")
    item << GovukTaxonomyHelpers::LinkedContentItem.new(title: "item2", base_path: "/item2", content_id: "id2")

    @root_taxon_id = 123
    allow(GovukTaxonomyHelpers::LinkedContentItem)
      .to receive(:from_content_id)
      .with(content_id: @root_taxon_id, publishing_api: Services.publishing_api)
      .and_return(item)
  end

  describe "#call" do
    it "spawns a worker for each id" do
      expect(PublishTaxonWorker).to receive(:perform_async).with("id1")
      expect(PublishTaxonWorker).to receive(:perform_async).with("id2")
      Taxonomy::BulkPublishTaxon.call(@root_taxon_id)
    end
  end
end
