require 'rails_helper'

RSpec.describe AlphaTaxonomy::SheetDownloader do
  describe "#sheet_credential_tuples" do
    context "given ENV is set with appropriate values" do
      it "returns an array of sheet credentials" do
        allow(ENV).to receive(:fetch).with("TAXON_SHEETS").and_return("sheet-name,the-key,the-gid")

        expect(AlphaTaxonomy::SheetDownloader.new(logger: StringIO.new).sheet_credential_tuples).to eq(
          [{ name: "sheet-name", key: "the-key", gid: "the-gid" }]
        )
      end
    end

    context "given ENV is set with inappropriate values" do
      it "raises an error" do
        allow(ENV).to receive(:fetch).with("TAXON_SHEETS").and_return("sheet-name,the-key,the-gid,another-sheet-name")

        expect { AlphaTaxonomy::SheetDownloader.new(logger: StringIO.new).sheet_credential_tuples }.to raise_error(
          ArgumentError
        )
      end
    end
  end
end
