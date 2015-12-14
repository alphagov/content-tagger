require "rails_helper"

RSpec.describe AlphaTaxonomy::CreateTaxons do
  describe "#run!" do
    context "an import file is not present" do
      before do
        allow(File).to receive(:exist?).with(AlphaTaxonomy::SheetDownloader.cache_location).and_return(false)
      end

      it "errors out" do
        expect { AlphaTaxonomy::CreateTaxons.new.run! }.to raise_error(
          AlphaTaxonomy::CreateTaxons::MissingImportFileError
        )
      end
    end

    context "an import file is present" do
      before do
        @temp_tsv = Tempfile.new("create_taxons_spec.tsv")
        @temp_tsv.write("taxon_title\tlink\n")
        @temp_tsv.write("Foo Taxon\tfoo-link/\n")
        @temp_tsv.write("Bar Taxon\tbar-link/\n")
        @temp_tsv.close
        allow(AlphaTaxonomy::SheetDownloader).to receive(:cache_location).and_return(@temp_tsv.path)

        @valid_uuid = "7d92d517-fb06-489b-84fe-4f6dfb439980"
        allow(SecureRandom).to receive(:uuid).and_return(@valid_uuid)
      end

      def stub_taxon_fetch(result:)
        allow(Services.publishing_api).to receive(:get_content_items).and_return(result)
      end

      after do
        @temp_tsv.unlink
      end

      context "none of the taxons in the input TSV exist yet" do
        before { stub_taxon_fetch(result: [{"base_path" => "/alpha-taxonomy/unrelated-taxon"}]) }

        it "creates each taxon" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .twice

          AlphaTaxonomy::CreateTaxons.new.run!
        end
      end

      context "a taxon appears twice" do
        before { stub_taxon_fetch(result: [{"base_path" => "/alpha-taxonomy/unrelated-taxon"}]) }
        before do
          File.open(@temp_tsv.path, "ab") do |file|
            file.write("Foo Taxon\tfoo-link/\n")
          end
        end

        it "is only created once" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .twice

          AlphaTaxonomy::CreateTaxons.new.run!
        end
      end

      context "one taxon already exists" do
        before { stub_taxon_fetch(result: [{"base_path" => "/alpha-taxonomy/foo-taxon"}]) }

        it "does not create that taxon" do
          expect(Services.publishing_api).to receive(:put_content)
            .with(@valid_uuid, be_valid_against_schema('taxon'))
            .once

          AlphaTaxonomy::CreateTaxons.new.run!
        end
      end
    end
  end
end
