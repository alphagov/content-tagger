require "rails_helper"

RSpec.describe PublishLinksWorker do
  describe "#perform" do
    it 'does not call the links publisher when the tag mapping was not found' do
      expect(BulkTagging::PublishLinks).to_not receive(:call)

      described_class.new.perform(1)
    end

    context 'with valid links' do
      before do
        allow_any_instance_of(BulkTagging::TagMapping).to receive(:valid?)
          .and_return(true)
      end

      it 'it calls the links publisher service when there is a tag mapping' do
        tag_mapping = create(:tag_mapping)
        expect(BulkTagging::PublishLinks).to receive(:call)

        described_class.new.perform(tag_mapping.id)
      end
    end

    context 'with invalid link updates' do
      let!(:tag_mapping) { create(:tag_mapping) }

      before do
        allow_any_instance_of(BulkTagging::TagMapping).to receive(:valid?)
          .and_return(false)
      end

      it 'does not call the publishing API and marks the taggings as errored' do
        expect(BulkTagging::PublishLinks).to_not receive(:call)

        described_class.new.perform(tag_mapping.id)
      end
    end
  end
end
