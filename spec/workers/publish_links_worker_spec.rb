require "rails_helper"

RSpec.describe PublishLinksWorker do
  let(:tag_mapping) { create(:tag_mapping) }

  describe "#perform" do
    it 'delegates the work to the links publisher service' do
      expect(TagImporter::LinksPublisher).to receive(:publish).with(
        base_path: '/a/base/path',
        tag_mappings: [tag_mapping],
        links: { 'taxons' => ['taxon1-content-id', 'taxon2-content-id'] }
      )

      described_class.new.perform(
        '/a/base/path',
        'tag_mapping_ids' => [tag_mapping.id],
        'taxons' => ['taxon1-content-id', 'taxon2-content-id'],
      )
    end
  end
end
