require 'rails_helper'

RSpec.describe PublishLinks do
  let(:content_id) { 'a-content-id' }
  let(:tag_mapping) do
    mapping = build(:tag_mapping, tagging_source: build(:tag_migration))
    publishing_api_has_lookups(
      mapping.content_base_path => content_id
    )
    mapping
  end

  describe '.call' do
    context 'with pre-existing links' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: { taxons: ['existing-content-id'] },
          version: 10
        )
      end

      it 'adds the new links to the existing list of links' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          tag_mapping.content_id,
          links: { 'taxons' => ['existing-content-id', tag_mapping.link_content_id] },
          previous_version: 10
        )

        described_class.new(tag_mapping: tag_mapping).publish
      end
    end

    context 'with the same pre-existing links' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: { taxons: [tag_mapping.link_content_id] },
          version: 10
        )
      end

      it "makes sure we don't duplicate the links" do
        expect(Services.publishing_api).to receive(:patch_links).with(
          tag_mapping.content_id,
          links: { 'taxons' => [tag_mapping.link_content_id] },
          previous_version: 10
        )

        described_class.new(tag_mapping: tag_mapping).publish
      end
    end

    context 'without existing links' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: { taxons: [] },
          version: 10
        )
      end

      it 'updates the links via the publishing API and marks the tagging as tagged' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          tag_mapping.content_id,
          links: { tag_mapping.link_type => [tag_mapping.link_content_id] },
          previous_version: 10
        )

        described_class.new(tag_mapping: tag_mapping).publish
      end
    end

    context 'with the option to delete the source link activated' do
      before do
        tagging_source = tag_mapping.tagging_source
        tagging_source.source_content_id = 'source-content-id'
        tagging_source.delete_source_link = true

        publishing_api_has_links(
          content_id: content_id,
          links: { taxons: ['source-content-id'] },
          version: 10
        )
      end

      it 'adds the new link and remove the old link in the same request' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          tag_mapping.content_id,
          links: { tag_mapping.link_type => [tag_mapping.link_content_id] },
          previous_version: 10
        )

        described_class.new(tag_mapping: tag_mapping).publish
      end
    end
  end
end
