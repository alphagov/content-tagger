require 'rails_helper'

RSpec.describe LinksPublisher do
  describe '#publish' do
    let(:links_update) do
      instance_double(LinksUpdate,
                      valid?: true,
                      content_id: 'a-content-id',
                      links_to_update: { 'taxons' => ['taxon1-content-id'] })
    end

    context 'with valid link updates with pre-existing links' do
      before do
        publishing_api_has_links(
          content_id: links_update.content_id,
          links: { taxons: ['existing-content-id'] },
          version: 10
        )
      end

      it 'adds the new links to the existing list of links' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          links_update.content_id,
          links: { 'taxons' => ['existing-content-id', 'taxon1-content-id'] },
          previous_version: 10
        )
        expect(links_update).to receive(:mark_as_tagged)

        described_class.new(links_update: links_update).publish
      end
    end

    context 'with valid link updates with the same pre-existing links' do
      before do
        publishing_api_has_links(
          content_id: links_update.content_id,
          links: { taxons: ['taxon1-content-id'] },
          version: 10
        )
      end

      it "makes sure we don't duplicate the links" do
        expect(Services.publishing_api).to receive(:patch_links).with(
          links_update.content_id,
          links: { 'taxons' => ['taxon1-content-id'] },
          previous_version: 10
        )
        expect(links_update).to receive(:mark_as_tagged)

        described_class.new(links_update: links_update).publish
      end
    end

    context 'with valid link updates without existing links' do
      before do
        publishing_api_has_links(
          content_id: links_update.content_id,
          links: { taxons: [] },
          version: 0
        )
      end

      it 'updates the links via the publishing API and marks the taggings as tagged' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          links_update.content_id,
          links: links_update.links_to_update,
          previous_version: 0
        )
        expect(links_update).to receive(:mark_as_tagged)

        described_class.new(links_update: links_update).publish
      end
    end

    context 'with invalid link updates' do
      let(:links_update) { instance_double(LinksUpdate, valid?: false) }

      it 'does not call the publishing API and marks the taggings as errored' do
        expect(Services.publishing_api).to_not receive(:patch_links)
        expect(links_update).to receive(:mark_as_errored)

        described_class.new(links_update: links_update).publish
      end
    end
  end
end
