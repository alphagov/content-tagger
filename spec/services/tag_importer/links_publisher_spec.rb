require 'rails_helper'

RSpec.describe TagImporter::LinksPublisher do
  shared_examples 'it does not update anything' do
    it "doesn't patch the links" do
      expect(Services.publishing_api).to_not receive(:patch_links)
    end

    it "returns false" do
      expect(links_publisher.publish).to be_falsy
    end
  end

  describe '#publish' do
    context 'without any tag mapping ids' do
      let(:links_publisher) do
        described_class.new(
          base_path: '/a/base/path',
          tag_mappings: TagMapping.all,
          links: {
            'taxons' => ['taxon1-content-id', 'taxon2-content-id']
          }
        )
      end

      it_behaves_like 'it does not update anything'
    end

    context 'with an invalid content id' do
      let(:tag_mapping) { create(:tag_mapping) }
      let(:links_publisher) do
        described_class.new(
          base_path: '/a/base/path',
          tag_mappings: TagMapping.where(id: tag_mapping.id),
          links: {
            'taxons' => ['taxon1-content-id', 'taxon2-content-id']
          }
        )
      end

      before do
        publishing_api_has_lookups("/a/base/path" => nil)
      end

      it_behaves_like 'it does not update anything'

      it 'sets the state and message of the tag mappings' do
        links_publisher.publish
        tag_mapping.reload

        expect(tag_mapping.state).to eq('errored')
        expect(tag_mapping.message).to match(/we could not find the associated content id/i)
      end
    end

    context 'with invalid link types' do
      let(:tag_mapping) { create(:tag_mapping) }
      let(:links_publisher) do
        described_class.new(
          base_path: '/content-1',
          tag_mappings: TagMapping.where(id: tag_mapping.id),
          links: {
            'taxons' => ['taxon1-content-id', 'taxon2-content-id'],
            'organisations' => ['org1-content-id']
          }
        )
      end

      before do
        publishing_api_has_lookups("/content-1" => "content-1-ID")
      end

      it_behaves_like 'it does not update anything'

      it 'sets the state and message of the tag mappings' do
        links_publisher.publish
        tag_mapping.reload

        expect(tag_mapping.state).to eq('errored')
        expect(tag_mapping.message).to match(/invalid link types found/i)
      end
    end

    context 'with unknown taxons' do
      let(:tag_mapping) { create(:tag_mapping) }
      let(:links_publisher) do
        described_class.new(
          base_path: '/content-1',
          tag_mappings: TagMapping.where(id: tag_mapping.id),
          links: {
            'taxons' => ['taxon1-content-id', 'taxon2-content-id'],
          }
        )
      end

      before do
        publishing_api_has_lookups("/content-1" => "content-1-ID")
        publishing_api_has_linkables(
          [{
            'title' => 'A taxon',
            'content_id' => 'taxon1-content-id',
          }],
          document_type: 'taxon'
        )
      end

      it_behaves_like 'it does not update anything'

      it 'sets the state and message of the tag mappings' do
        links_publisher.publish
        tag_mapping.reload

        expect(tag_mapping.state).to eq('errored')
        expect(tag_mapping.message).to match(/invalid taxons found/i)
      end
    end

    context 'with valid taxons' do
      let(:tag_mapping) { create(:tag_mapping) }
      let(:links_publisher) do
        described_class.new(
          base_path: '/content-1',
          tag_mappings: TagMapping.where(id: tag_mapping.id),
          links: {
            'taxons' => ['taxon1-content-id'],
          }
        )
      end

      before do
        publishing_api_has_lookups("/content-1" => "content-1-ID")
        publishing_api_has_linkables(
          [{
            'title' => 'A taxon',
            'content_id' => 'taxon1-content-id',
          }],
          document_type: 'taxon'
        )
      end

      it 'allows us to update the links of the given content id' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          'content-1-ID',
          links: { 'taxons' => ['taxon1-content-id'] }
        )

        links_publisher.publish
        tag_mapping.reload
        expect(tag_mapping.state).to eq('tagged')
      end
    end
  end
end
