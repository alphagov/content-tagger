module BulkTagging
  RSpec.describe TaggingSpreadsheet do
    describe "#state" do
      context "valid states" do
        it "can be in an imported state" do
          expect(build(:tagging_spreadsheet, state: :imported)).to be_valid
        end

        it "can be in a ready to import state" do
          expect(build(:tagging_spreadsheet, state: :ready_to_import)).to be_valid
        end

        it "can be in an error state" do
          expect(build(:tagging_spreadsheet, state: :errored)).to be_valid
        end

        it "can be in an uploaded state" do
          expect(build(:tagging_spreadsheet, state: :uploaded)).to be_valid
        end
      end
    end

    describe "#mark_as_deleted" do
      it "updates the deleted_at date" do
        tagging_spreadsheet = build(:tagging_spreadsheet)
        expect(tagging_spreadsheet.deleted_at).to be_nil

        tagging_spreadsheet.mark_as_deleted
        expect(tagging_spreadsheet.deleted_at).to_not be_nil
      end
    end

    describe "#aggregated_tag_mappings" do
      before do
        @tagging_spreadsheet = build(:tagging_spreadsheet)
        @tagging_spreadsheet.tag_mappings << build(:tag_mapping, content_base_path: "/a/path", link_content_id: "a-content-id-1", link_title: "Education")
        @tagging_spreadsheet.tag_mappings << build(:tag_mapping, content_base_path: "/a/path", link_content_id: "a-content-id-2", link_title: "Early Years")
        @tagging_spreadsheet.tag_mappings << build(:tag_mapping, content_base_path: "/b/path", link_content_id: "a-content-id-2", link_title: "Early Years")
        @tagging_spreadsheet.save!

        @aggregated_tag_mappings = @tagging_spreadsheet.aggregated_tag_mappings
      end

      it "returns an array of AggregatedTagMappings" do
        expect(@aggregated_tag_mappings.class).to eql(Array)
        expect(@aggregated_tag_mappings.first.class).to eql(AggregatedTagMapping)
      end

      it "returns the expected aggregated tag mappings" do
        expect(@aggregated_tag_mappings.first.content_base_path).to eql("/a/path")
        expect(@aggregated_tag_mappings.first.tag_mappings.count).to eql(2)

        expect(@aggregated_tag_mappings.last.content_base_path).to eql("/b/path")
        expect(@aggregated_tag_mappings.last.tag_mappings.count).to eql(1)
      end
    end
  end
end
