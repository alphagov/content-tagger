module BulkTagging
  RSpec.describe BuildTagMigration do
    include PublishingApiHelper
    include ContentItemHelper

    context "without any taxons" do
      let(:tag_migration) do
        described_class.call(
          source_content_item: stub_content_item,
          taxon_content_ids: [],
          content_base_paths: ["/content-1"],
        )
      end

      it "raises an error" do
        expect { tag_migration }.to raise_error(
          BuildTagMigration::InvalidArgumentError,
          /no taxons selected/i,
        )
      end
    end

    context "without any content items" do
      let(:tag_migration) do
        described_class.call(
          source_content_item: stub_content_item,
          taxon_content_ids: %w[taxon-1],
          content_base_paths: [],
        )
      end

      it "raises an error" do
        expect { tag_migration }.to raise_error(
          BuildTagMigration::InvalidArgumentError,
          /no content items selected/i,
        )
      end
    end

    context "with 2 valid taxons and 2 content base paths" do
      before do
        stub_publishing_api_has_item(basic_content_item("Taxon 1", other_fields: { base_path: "/foo", content_id: "taxon-1" }))
        stub_publishing_api_has_item(basic_content_item("Taxon 2", other_fields: { base_path: "/ha", content_id: "taxon-2" }))
      end

      let(:tag_migration) do
        described_class.call(
          source_content_item: stub_content_item,
          taxon_content_ids: %w[taxon-1 taxon-2],
          content_base_paths: ["/content-1", "/content-2"],
        )
      end

      it "builds an instance of a TagMigration" do
        expect(tag_migration).to be_a(TagMigration)
      end

      it "builds a valid object" do
        expect(tag_migration).to be_valid
      end

      it "assigns the source tag content id to the tag migration" do
        expect(tag_migration.source_content_id).to eq("content-id")
      end

      it "assigns an initial state to the tag migration" do
        expect(tag_migration.state).to eq("ready_to_import")
      end

      it "builds 4 tag mappings" do
        expect(tag_migration.tag_mappings.length).to eq(4)
      end

      it "delegates the initialization of TagMapping records" do
        expect(BuildTagMapping).to receive(:call)
          .exactly(4)
          .times
          .and_return(TagMapping.new)

        tag_migration
      end
    end

    def stub_content_item
      ContentItem.new(basic_content_item("Some random title", other_fields: { content_id: "content-id" }))
    end
  end
end
