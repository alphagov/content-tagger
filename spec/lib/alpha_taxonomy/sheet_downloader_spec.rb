require 'rails_helper'

RSpec.describe AlphaTaxonomy::SheetDownloader do
  describe "#new" do
    context "sheet identifiers are set with appropriate values" do
      it "correctly parses the identifiers into an array of tuples" do
        downloader = AlphaTaxonomy::SheetDownloader.new(
          logger: StringIO.new,
          sheet_identifiers: ["sheet-name", "the-key", "the-gid"]
        )

        expect(downloader.sheet_identifier_tuples).to eq(
          [{ name: "sheet-name", key: "the-key", gid: "the-gid" }]
        )
      end
    end

    context "given ENV is set with inappropriate values" do
      it "raises an error" do
        instantiate_downloader = lambda do
          AlphaTaxonomy::SheetDownloader.new(
            logger: StringIO.new,
            sheet_identifiers: ["sheet-name", "the-key", "the-gid", "another-sheet-name"]
          )
        end

        expect(instantiate_downloader).to raise_error(ArgumentError)
      end
    end
  end
end
