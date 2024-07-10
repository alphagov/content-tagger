RSpec.describe Taxonomy::TaxonUnpublisher do
  include ::GdsApi::TestHelpers::PublishingApi

  let(:taxon_content_id) { SecureRandom.uuid }
  let(:parent_taxon_content_id) { SecureRandom.uuid }
  let(:redirect_content_id) { SecureRandom.uuid }
  let(:tagged_content_id_one) { SecureRandom.uuid }
  let(:tagged_content_id_two) { SecureRandom.uuid }
  let(:version) { 10 }

  before do
    # parent and child taxon, redirect taxon exist
    stub_publishing_api_has_item(FactoryBot.build(:taxon_hash, content_id: taxon_content_id))
    stub_publishing_api_has_item(FactoryBot.build(:taxon_hash, content_id: parent_taxon_content_id))
    stub_publishing_api_has_item("content_id" => redirect_content_id, "base_path" => "/path/to/redirect")

    # link parent taxon to child taxon
    stub_publishing_api_has_expanded_links(expanded_links(taxon_content_id, parent_taxon_content_id))
    stub_any_publishing_api_unpublish
  end

  context "when the taxon is not tagged to any content items" do
    before do
      # no content items are tagged to child taxon
      stub_publishing_api_has_linked_items(
        [],
        content_id: taxon_content_id,
        link_type: "taxons",
        fields: %w[base_path],
      )
    end

    it "does not perform a tag migration" do
      expect(BulkTagging::BuildTagMigration).not_to receive(:call)
      unpublish(taxon_content_id, redirect_content_id)
    end
  end

  context "when the taxon is tagged to two content items" do
    before do
      # content items are tagged to child taxon
      stub_publishing_api_has_linked_items(
        [{ "base_path" => "/base/path1" },
         { "base_path" => "/base/path2" }],
        content_id: taxon_content_id,
        link_type: "taxons",
        fields: %w[base_path],
      )
      stub_publishing_api_has_lookups("/base/path1" => tagged_content_id_one, "/base/path2" => tagged_content_id_two)

      # each content item has links to child taxon
      stub_publishing_api_has_links(content_id: tagged_content_id_one, links: { taxons: [taxon_content_id] }, version:)
      stub_publishing_api_has_links(content_id: tagged_content_id_two, links: { taxons: [taxon_content_id] }, version:)
    end

    it "unpublishes a level one taxon with a redirect" do
      stub_publishing_api_has_expanded_links({ "content_id" => taxon_content_id, "expanded_links" => {} })
      unpublish(taxon_content_id, redirect_content_id)
      assert_publishing_api_unpublish(taxon_content_id, type: "redirect", alternative_path: "/path/to/redirect")
    end

    describe "tag to parent" do
      before do
        stub_any_publishing_api_unpublish
      end

      it "retags content to the parent" do
        patch_request1 = stub_publishing_api_patch_links(tagged_content_id_one, hash_including(links: { taxons: [taxon_content_id, parent_taxon_content_id] }, previous_version: version))
        patch_request2 = stub_publishing_api_patch_links(tagged_content_id_two, hash_including(links: { taxons: [taxon_content_id, parent_taxon_content_id] }, previous_version: version))
        unpublish(taxon_content_id, redirect_content_id)
        expect(patch_request1).to have_been_made
        expect(patch_request2).to have_been_made
      end

      it "does not retag content" do
        patch_request = stub_any_publishing_api_patch_links
        unpublish(taxon_content_id, redirect_content_id, retag: false)
        expect(patch_request).not_to have_been_made
      end
    end
  end

  def unpublish(taxon_content_id, redirect_to_content_id, retag: true)
    Sidekiq::Testing.inline! do
      Taxonomy::TaxonUnpublisher.call(taxon_content_id:, redirect_to_content_id:, user: User.new, retag:)
    end
  end

  def expanded_links(content_id, parent_content_id)
    {
      "content_id" => content_id,
      "expanded_links" =>
        {
          "parent_taxons" =>
            [
              {
                "content_id" => parent_content_id,
              },
            ],
        },
    }
  end
end
