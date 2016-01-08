require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonCreator do
  describe "#run!" do
    def run_the_taxon_creator!
      # Instantiate with a dummy logger to keep stdout noise-free
      AlphaTaxonomy::TaxonCreator.new(logger: Logger.new(StringIO.new)).run!
    end

    context "an import file is not present" do
      before do
        allow(File).to receive(:exist?).with(AlphaTaxonomy::ImportFile.location).and_return(false)
      end

      it "errors out" do
        expect { run_the_taxon_creator! }.to raise_error(
          AlphaTaxonomy::SharedExceptions::MissingImportFileError
        )
      end
    end

    context "an import file is present" do
      before do
        # Create a temporary TSV file containing test data
        @temp_tsv = Tempfile.new("taxon_creator_spec.tsv")
        @temp_tsv.write("taxon_title\tlink\n")
        @temp_tsv.write("Foo Taxon\tfoo-link/\n")
        @temp_tsv.write("Bar Taxon\tbar-link/\n")
        @temp_tsv.close
        allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return(@temp_tsv.path)

        # Make uuid generation deterministic
        @valid_uuid = "7d92d517-fb06-489b-84fe-4f6dfb439980"
        allow(SecureRandom).to receive(:uuid).and_return(@valid_uuid)

        # We log the response code from the publishing API, stub out the returned value
        allow(Services.publishing_api).to receive(:put_content).and_return(double(code: 200))
        allow(Services.publishing_api).to receive(:publish).and_return(double(code: 200))
      end

      def stub_taxon_fetch(results:)
        mock_response = double(to_a: results)
        allow(Services.publishing_api).to receive(:get_content_items).and_return(mock_response)
      end

      after do
        @temp_tsv.unlink
      end

      context "none of the taxons in the input TSV exist yet" do
        before { stub_taxon_fetch(results: [{ "base_path" => "/alpha-taxonomy/unrelated-taxon" }]) }

        it "creates each taxon" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .twice
          expect(Services.publishing_api).to receive(:publish)
            .with(@valid_uuid, "major")
            .twice

          run_the_taxon_creator!
        end
      end

      context "a taxon appears twice" do
        before { stub_taxon_fetch(results: [{ "base_path" => "/alpha-taxonomy/unrelated-taxon" }]) }
        before do
          File.open(@temp_tsv.path, "ab") do |file|
            file.write("Foo Taxon\tfoo-link/\n")
          end
        end

        it "is only created once" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .twice
          expect(Services.publishing_api).to receive(:publish)
            .with(@valid_uuid, "major")
            .twice

          run_the_taxon_creator!
        end
      end

      context "one taxon already exists" do
        before { stub_taxon_fetch(results: [{ "base_path" => "/alpha-taxonomy/foo-taxon" }]) }

        it "does not create that taxon" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .once
          expect(Services.publishing_api).to receive(:publish)
            .with(@valid_uuid, "major")
            .once

          run_the_taxon_creator!
        end
      end
    end
  end
end
