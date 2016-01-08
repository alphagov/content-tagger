require "rails_helper"

RSpec.describe AlphaTaxonomy::ImportFile do
  let(:test_tsv_file_path) do
    FileUtils.mkdir_p Rails.root + "tmp"
    Rails.root + "tmp/import_file_spec.csv"
  end
  let(:sheet_downloader) { AlphaTaxonomy::SheetDownloader.new }

  before do
    allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return(test_tsv_file_path)
    allow(AlphaTaxonomy::SheetDownloader).to receive(:new).and_return(sheet_downloader)
  end

  after do
    File.delete(test_tsv_file_path) if File.exist?(test_tsv_file_path)
  end

  def stub_downloaded_sheet_data(tsv_rows)
    # Create a string of tsv data from an array of rows, resulting in
    # tab-seperated values with newlines delimiting each row.
    headers = ["mapped to\tlink"]
    sheet_data = (headers + tsv_rows).join("\n") + "\n"
    allow(sheet_downloader).to receive(:each_sheet).and_yield(sheet_data)
  end

  describe "#populate" do
    def expected_tsv_content(tsv_rows)
      (["taxon_title\tbase_path"] + tsv_rows).join("\n") + "\n"
    end

    it "parses and writes the required data to a file" do
      stub_downloaded_sheet_data([
        "Foo-Taxon\t" + "/foo-content-item-path",
        "Bar (Br)| Baz (Bz)\t" + "/bar-or-baz-content-item-path",
        "n/a - not applicable\t" + "/n/a-content-item-path",
      ])

      AlphaTaxonomy::ImportFile.new.populate

      populated_file = File.open(test_tsv_file_path)
      expect(populated_file.read).to eq(
        expected_tsv_content([
          "Foo-Taxon\t/foo-content-item-path",
          "Bar (Br)\t/bar-or-baz-content-item-path",
          "Baz (Bz)\t/bar-or-baz-content-item-path"
        ])
      )
    end

    it "reports an error and removes the file if the required values aren't present" do
      stub_downloaded_sheet_data(["\t" + "the-foo-slug"])

      log_output = StringIO.new
      AlphaTaxonomy::ImportFile.new(logger: Logger.new(log_output)).populate

      log_output.rewind
      expect(log_output.read).to match(/Missing value in downloaded taxonomy spreadsheet/)
      expect(File.exist?(test_tsv_file_path)).to be false
    end

    it "reports an error and removes the file if the expected columns aren't present" do
      test_tsv_data = [
        "some random column name\t" + "link",
        "Foo Taxon (Label)\t" + "the-foo-slug",
      ].join("\n")
      allow(sheet_downloader).to receive(:each_sheet).and_yield(test_tsv_data)

      log_output = StringIO.new
      AlphaTaxonomy::ImportFile.new(logger: Logger.new(log_output)).populate

      log_output.rewind
      expect(log_output.read).to match(/Column names in downloaded taxonomy data did not match expected values/)
      expect(File.exist?(test_tsv_file_path)).to be false
    end
  end

  describe "#grouped_mappings" do
    context "if the import file is present" do
      before do
        stub_downloaded_sheet_data([
          "Foo-Taxon\t" + "/foo-content-item-path",
          "Bar (Br)| Baz (Bz)\t" + "/bar-or-baz-content-item-path",
        ])
        AlphaTaxonomy::ImportFile.new.populate
      end

      it "returns lists of taxons grouped by base_path" do
        expect(AlphaTaxonomy::ImportFile.new.grouped_mappings).to eq(
          "/foo-content-item-path" => ["Foo-Taxon"],
          "/bar-or-baz-content-item-path" => ["Bar (Br)", "Baz (Bz)"]
        )
      end
    end

    context "if the import file is missing" do
      it "raises an error" do
        allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return("/some-crazy-non-existing-path")

        expect { AlphaTaxonomy::ImportFile.new.grouped_mappings }.to raise_error(
          AlphaTaxonomy::SharedExceptions::MissingImportFileError
        )
      end
    end
  end
end
