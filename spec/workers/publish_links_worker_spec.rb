require "rails_helper"

RSpec.describe PublishLinksWorker do
  describe "#perform" do
    it 'does not call the links publisher when no taggings are available' do
      expect(PublishLinks).to_not receive(:publish)

      described_class.new.perform(
        '/a/base/path',
        'tag_mapping_ids' => [],
        'taxons' => ['taxon1-content-id'],
      )
    end

    it 'it calls the links publisher service when there are tag mappings' do
      tag_mapping = create(:tag_mapping)
      expect(PublishLinks).to receive(:publish)

      described_class.new.perform(
        '/a/base/path',
        'tag_mapping_ids' => [tag_mapping.id],
        'taxons' => ['taxon1-content-id'],
      )
    end
  end
end
