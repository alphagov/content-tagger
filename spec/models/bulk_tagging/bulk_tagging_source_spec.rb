module BulkTagging
  RSpec.describe BulkTaggingSource do
    describe "#source_names" do
      it "returns the names of all supported link types" do
        expect(described_class.new.source_names).to eq(
          %i[document_collection topic mainstream_browse_page taxon],
        )
      end
    end

    describe "#content_key_for(source_name)" do
      it "correctly returns the content key for the given source name" do
        expect(described_class.new.content_key_for(:document_collection)).to eq "documents"
        expect(described_class.new.content_key_for("topic")).to eq "children"
        expect(described_class.new.content_key_for(:mainstream_browse_page)).to eq "children"
        expect(described_class.new.content_key_for(:taxon)).to eq "taxon"
      end
    end
  end
end
