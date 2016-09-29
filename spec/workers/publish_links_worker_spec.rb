require "rails_helper"

RSpec.describe PublishLinksWorker do
  describe "#perform" do
    it 'does not call the links publisher when no taggings are available' do
      expect(PublishLinks).to_not receive(:call)

      described_class.new.perform(
        '/a/base/path',
        'tag_mapping_ids' => [],
        'taxons' => ['taxon1-content-id'],
      )
    end

    context 'with valid links' do
      before do
        allow_any_instance_of(LinksUpdate).to receive(:valid?).and_return(true)
      end

      it 'it calls the links publisher service when there are tag mappings' do
        tag_mapping = create(:tag_mapping)
        expect(PublishLinks).to receive(:call)

        described_class.new.perform(
          '/a/base/path',
          'tag_mapping_ids' => [tag_mapping.id],
          'taxons' => ['taxon1-content-id'],
        )
      end
    end

    context 'with invalid link updates' do
      before do
        allow_any_instance_of(LinksUpdate).to receive(:valid?).and_return(false)
      end

      it 'does not call the publishing API and marks the taggings as errored' do
        tag_mapping = create(:tag_mapping)
        expect(PublishLinks).to_not receive(:call)

        described_class.new.perform(
          '/a/base/path',
          'tag_mapping_ids' => [tag_mapping.id],
          'taxons' => ['taxon1-content-id'],
        )
      end
    end
  end
end
