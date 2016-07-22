require "rails_helper"
require "tempfile"

RSpec.describe AlphaTaxonomy::ImportFileGroupings do
  describe "#extract" do
    context "if the import file is present and contains taxon data" do
      before do
        @temp_import_file = Tempfile.new('import_file_groupings_spec')
        allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return(@temp_import_file.path)
        allow(CSV).to receive(:read)
          .with(AlphaTaxonomy::ImportFile.location, col_sep: "\t", headers: true)
          .and_return(
            [
              { "base_path" => "/foo-content-item-path", "taxon_title" => "foo-taxon" },
              { "base_path" => "/bar-or-baz-content-item-path", "taxon_title" => "bar-taxon" },
              { "base_path" => "/bar-or-baz-content-item-path", "taxon_title" => "baz-taxon" },
            ]
          )
      end

      after do
        @temp_import_file.close
        @temp_import_file.unlink
      end

      it "returns lists of taxons grouped by base_path" do
        expect(AlphaTaxonomy::ImportFileGroupings.new.extract).to eq(
          "/foo-content-item-path" => ["foo-taxon"],
          "/bar-or-baz-content-item-path" => ["bar-taxon", "baz-taxon"]
        )
      end
    end

    context "if the import file is missing" do
      it "raises an error" do
        allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return("/some-crazy-non-existing-path")
        expect { AlphaTaxonomy::ImportFileGroupings.new.extract }.to raise_error(AlphaTaxonomy::SharedExceptions::MissingImportFileError)
      end
    end
  end
end
