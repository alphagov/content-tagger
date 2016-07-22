require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonLinker do
  require 'gds_api/test_helpers/publishing_api_v2'
  include GdsApi::TestHelpers::PublishingApiV2

  describe "#run!" do
    def run_the_taxon_linker!
      AlphaTaxonomy::TaxonLinker.new(logger: Logger.new(StringIO.new)).run!
    end

    def stub_taxons_fetch(returned_taxon_collection)
      allow(Services.publishing_api).to receive(:get_linkables).with(
        document_type: 'taxon'
      ).and_return(returned_taxon_collection.map(&:stringify_keys))
    end

    def stub_import_file_groupings(returned_groupings)
      mock_grouping_object = double(AlphaTaxonomy::ImportFileGroupings, extract: returned_groupings)
      allow(AlphaTaxonomy::ImportFileGroupings).to receive(:new).and_return(mock_grouping_object)
    end

    before do
      # We log the response code from the publishing API, stub out the returned value
      allow(Services.publishing_api).to receive(:patch_links).and_return(double(code: 200))
    end

    it "creates taxon links based on the grouped mappings" do
      stub_import_file_groupings(
        "/a-foo-content-item" => ["Foo Taxon"],
        "/a-foo-bar-content-item" => ["foo Taxon", "Bar Taxon"]
      )
      stub_taxons_fetch(
        [
          { content_id: "foo-taxon-uuid", base_path: "/alpha-taxonomy/foo-taxon" },
          { content_id: "bar-taxon-uuid", base_path: "/alpha-taxonomy/bar-taxon" },
        ]
      )

      publishing_api_has_lookups(
        "/a-foo-content-item" => "foo-item-uuid",
        "/a-foo-bar-content-item" => "foo-bar-item-uuid",
      )

      expect(Services.publishing_api).to receive(:patch_links).with(
        "foo-item-uuid",
        links: { taxons: ["foo-taxon-uuid"] }
      ).once
      expect(Services.publishing_api).to receive(:patch_links).with(
        "foo-bar-item-uuid",
        links: { taxons: ["foo-taxon-uuid", "bar-taxon-uuid"] }
      ).once

      run_the_taxon_linker!
    end

    context "the import file taxons have inconsistent capitalisation" do
      before do
        stub_import_file_groupings(
          "/a-foo-content-item" => ["Foo Taxon"],
          "/a-foo-bar-content-item" => ["foo tAxon"]
        )
      end

      it "gracefully handles this by looking up the content ID with a base_path" do
        stub_taxons_fetch(
          [
            { content_id: "foo-taxon-uuid", base_path: "/alpha-taxonomy/foo-taxon" },
          ]
        )

        publishing_api_has_lookups(
          "/a-foo-content-item" => "foo-item-uuid",
          "/a-foo-bar-content-item" => "foo-bar-item-uuid",
        )

        expect(Services.publishing_api).to receive(:patch_links).with(
          "foo-item-uuid",
          links: { taxons: ["foo-taxon-uuid"] }
        ).once
        expect(Services.publishing_api).to receive(:patch_links).with(
          "foo-bar-item-uuid",
          links: { taxons: ["foo-taxon-uuid"] }
        ).once

        run_the_taxon_linker!
      end
    end

    context "when a duplicate mapping exists" do
      before do
        stub_import_file_groupings(
          "/a-foo-content-item" => ["Foo Taxon", "Foo Taxon"],
        )
      end

      it "does not duplicate content IDs in the patch_links payload" do
        stub_taxons_fetch(
          [
            { content_id: "foo-taxon-uuid", base_path: "/alpha-taxonomy/foo-taxon" },
          ]
        )

        publishing_api_has_lookups(
          "/a-foo-content-item" => "foo-item-uuid"
        )

        expect(Services.publishing_api).to receive(:patch_links).with(
          "foo-item-uuid",
          links: { taxons: ["foo-taxon-uuid"] }
        ).once

        run_the_taxon_linker!
      end
    end

    context "when the grouped mappings contain a taxon not present in the content store" do
      it "raises an error" do
        stub_import_file_groupings("/a-foo-content-item" => ["Foo Taxon"])
        stub_taxons_fetch([{ content_id: "irrelevant", base_path: "/alpha-taxonomy/other-taxon" }])

        expect { run_the_taxon_linker! }.to raise_error(
          AlphaTaxonomy::TaxonLinker::TaxonNotInContentStoreError
        )
      end
    end

    context "when the target content_item is not found by the lookup" do
      before do
        stub_import_file_groupings("/a-foo-content-item" => ["Foo Taxon"], "/invalid-content-item" => ["Foo Taxon"])
        stub_taxons_fetch([{ content_id: "foo-taxon-uuid", base_path: "/alpha-taxonomy/foo-taxon" }])

        publishing_api_has_lookups(
          "/a-foo-content-item" => "foo-item-uuid",
        )
      end

      it "does not create a link and reports the error" do
        expect(Services.publishing_api).to receive(:patch_links).with(
          "foo-item-uuid",
          links: { taxons: ["foo-taxon-uuid"] }
        ).once

        log_output = StringIO.new
        AlphaTaxonomy::TaxonLinker.new(logger: Logger.new(log_output)).run!
        log_output.rewind
        expect(log_output.read).to match(%r{No content item found at /invalid-content-item})
      end
    end
  end
end
