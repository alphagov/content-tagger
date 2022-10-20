require "rails_helper"

module BulkTagging
  RSpec.describe PublishLinks do
    before do
      allow(Services.publishing_api).to receive(:patch_links)
    end

    let(:content_id) { "a-content-id" }
    let(:tag_mapping) do
      mapping = build(:tag_mapping, tagging_source: build(:tag_migration))
      stub_publishing_api_has_lookups(
        mapping.content_base_path => content_id,
      )
      mapping
    end

    describe ".call" do
      it "adds the new links to the existing list of links" do
        stub_publishing_api_has_links(
          content_id:,
          links: { taxons: %w[existing-content-id] },
          version: 10,
        )

        described_class.new(tag_mapping:).publish

        expect(Services.publishing_api).to have_received(:patch_links).with(
          tag_mapping.content_id,
          links: { "taxons" => ["existing-content-id", tag_mapping.link_content_id] },
          previous_version: 10,
          bulk_publishing: true,
        )
      end

      it "makes sure we don't duplicate the links" do
        stub_publishing_api_has_links(
          content_id:,
          links: { taxons: [tag_mapping.link_content_id] },
          version: 10,
        )

        described_class.new(tag_mapping:).publish

        expect(Services.publishing_api).to have_received(:patch_links).with(
          tag_mapping.content_id,
          links: { "taxons" => [tag_mapping.link_content_id] },
          previous_version: 10,
          bulk_publishing: true,
        )
      end

      it "adds new links" do
        stub_publishing_api_has_links(
          content_id:,
          links: { taxons: [] },
          version: 10,
        )

        described_class.new(tag_mapping:).publish

        expect(Services.publishing_api).to have_received(:patch_links).with(
          tag_mapping.content_id,
          links: { tag_mapping.link_type => [tag_mapping.link_content_id] },
          previous_version: 10,
          bulk_publishing: true,
        )
      end

      it "adds replaces the link in the same request when if delete source link is chosen" do
        tagging_source = tag_mapping.tagging_source
        tagging_source.source_content_id = "source-content-id"
        tagging_source.delete_source_link = true

        stub_publishing_api_has_links(
          content_id:,
          links: { taxons: %w[source-content-id] },
          version: 10,
        )

        described_class.new(tag_mapping:).publish

        expect(Services.publishing_api).to have_received(:patch_links).with(
          tag_mapping.content_id,
          links: { tag_mapping.link_type => [tag_mapping.link_content_id] },
          previous_version: 10,
          bulk_publishing: true,
        )
      end
    end
  end
end
