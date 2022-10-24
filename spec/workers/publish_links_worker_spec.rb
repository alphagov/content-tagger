RSpec.describe PublishLinksWorker do
  describe "#perform" do
    it "does not call the links publisher when the tag mapping was not found" do
      expect(BulkTagging::PublishLinks).not_to receive(:call)

      described_class.new.perform(1)
    end

    context "with valid links" do
      before do
        mapping_double = instance_double(
          BulkTagging::TagMapping,
          valid?: true,
          errors: [],
          mark_as_errored: nil,
          mark_as_tagged: nil,
        )
        allow(BulkTagging::TagMapping).to receive(:find_by_id).and_return(mapping_double)
      end

      it "calls the links publisher service when there is a tag mapping" do
        tag_mapping = create(:tag_mapping)
        expect(BulkTagging::PublishLinks).to receive(:call)

        described_class.new.perform(tag_mapping.id)
      end
    end

    context "with invalid link updates" do
      let!(:tag_mapping) { create(:tag_mapping) }

      before do
        mapping_double = instance_double(
          BulkTagging::TagMapping,
          valid?: false,
          errors: [],
          mark_as_errored: nil,
          mark_as_tagged: nil,
        )
        allow(BulkTagging::TagMapping).to receive(:find_by_id).and_return(mapping_double)
      end

      it "does not call the publishing API and marks the taggings as errored" do
        expect(BulkTagging::PublishLinks).not_to receive(:call)

        described_class.new.perform(tag_mapping.id)
      end
    end
  end
end
