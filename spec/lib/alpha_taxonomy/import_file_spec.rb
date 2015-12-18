require "rails_helper"

RSpec.describe AlphaTaxonomy::ImportFile do
  describe ".populate" do
    let(:test_output_path) { Rails.root + "tmp/import_file_spec.csv" }
    let(:sheet_downloader) { AlphaTaxonomy::SheetDownloader.new }

    before do
      allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return(test_output_path)
      allow(AlphaTaxonomy::SheetDownloader).to receive(:new).and_return(sheet_downloader)
    end

    after do
      File.delete(test_output_path) if File.exist?(test_output_path)
    end

    it "parses and writes the required data to a file" do
      test_tsv_data = [
        "mapped to\t" + "link",
        "Foo-Taxon\t" + "the-foo-link",
        "Bar (Br)| Baz (Bz)\t" + "the-bar-or-baz-link",
        "n/a - not applicable\t" + "the-n/a-link",
      ].join("\n")
      allow(sheet_downloader).to receive(:each_sheet).and_yield(test_tsv_data)

      AlphaTaxonomy::ImportFile.new.populate

      populated_file = File.open(test_output_path)
      expect(populated_file.read.split("\n")).to eq([
        "taxon_title\tlink",
        "Foo-Taxon\tthe-foo-link",
        "Bar (Br)\tthe-bar-or-baz-link",
        "Baz (Bz)\tthe-bar-or-baz-link"
      ])
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
      expect(File.exist?(test_output_path)).to be false
    end

    it "reports an error and removes the file if the required values aren't present" do
      test_tsv_data = [
        "mapped to\t" + "link",
        "\t" + "the-foo-slug",
      ].join("\n")
      allow(sheet_downloader).to receive(:each_sheet).and_yield(test_tsv_data)

      log_output = StringIO.new
      AlphaTaxonomy::ImportFile.new(logger: Logger.new(log_output)).populate

      log_output.rewind
      expect(log_output.read).to match(/Missing value in downloaded taxonomy spreadsheet/)
      expect(File.exist?(test_output_path)).to be false
    end
  end
end
