module BulkTagging
  RSpec.describe TaggingSpreadsheet do
    describe "#state" do
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

    describe "#mark_as_deleted" do
      it "updates the deleted_at date" do
        tagging_spreadsheet = build(:tagging_spreadsheet)
        expect(tagging_spreadsheet.deleted_at).to be_nil

        tagging_spreadsheet.mark_as_deleted
        expect(tagging_spreadsheet.deleted_at).not_to be_nil
      end
    end

    describe "#aggregated_tag_mappings" do
      let(:tagging_spreadsheet) do
        build(:tagging_spreadsheet).tap do |ts|
          ts.tag_mappings << build(:tag_mapping, content_base_path: "/a/path", link_content_id: "a-content-id-1", link_title: "Education")
          ts.tag_mappings << build(:tag_mapping, content_base_path: "/a/path", link_content_id: "a-content-id-2", link_title: "Early Years")
          ts.tag_mappings << build(:tag_mapping, content_base_path: "/b/path", link_content_id: "a-content-id-2", link_title: "Early Years")
          ts.save!
        end
      end

      it "returns an array of AggregatedTagMappings" do
        mappings = tagging_spreadsheet.aggregated_tag_mappings

        expect(mappings.class).to eql(Array)
        expect(mappings.first.class).to eql(AggregatedTagMapping)
      end

      it "returns the expected aggregated tag mappings" do
        mappings = tagging_spreadsheet.aggregated_tag_mappings

        expect(mappings.first.content_base_path).to eql("/a/path")
        expect(mappings.first.tag_mappings.count).to be(2)

        expect(mappings.last.content_base_path).to eql("/b/path")
        expect(mappings.last.tag_mappings.count).to be(1)
      end
    end
  end
end
