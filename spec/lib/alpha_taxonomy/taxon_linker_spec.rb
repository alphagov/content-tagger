require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonLinker do
  describe "#run!" do
    def stub_taxons_fetch(returned_taxon_collection)
      allow(Services.publishing_api).to receive(:get_content_items).with(
        content_format: 'taxon', fields: %i(title base_path content_id)
      ).and_return(returned_taxon_collection.map(&:stringify_keys))
    end

    def stub_content_item_lookup(base_path:, content_id:)
      lookup = double(valid?: true)
      allow(lookup).to receive(:content_id).and_return(content_id)
      allow(ContentLookupForm).to receive(:new).with(base_path: base_path).and_return(lookup)
    end

    def stub_import_file_mappings(returned_mappings)
      import_file = AlphaTaxonomy::ImportFile.new
      allow(import_file).to receive(:grouped_mappings).and_return(returned_mappings)
      allow(AlphaTaxonomy::ImportFile).to receive(:new).and_return(import_file)
    end

    it "creates taxon links based on the grouped mappings" do
      stub_import_file_mappings(
        "/a-foo-content-item" => ["Foo Taxon"],
        "/a-foo-bar-content-item" => ["Foo Taxon", "Bar Taxon"]
      )
      stub_taxons_fetch([
        { title: "Foo Taxon", content_id: "foo-taxon-uuid" },
        { title: "Bar Taxon", content_id: "bar-taxon-uuid" },
      ])
      stub_content_item_lookup(base_path: "/a-foo-content-item", content_id: "foo-item-uuid")
      stub_content_item_lookup(base_path: "/a-foo-bar-content-item", content_id: "foo-bar-item-uuid")

      expect(Services.publishing_api).to receive(:put_links).with(
        "foo-item-uuid",
        links: { alpha_taxons: ["foo-taxon-uuid"] }
      ).once
      expect(Services.publishing_api).to receive(:put_links).with(
        "foo-bar-item-uuid",
        links: { alpha_taxons: ["foo-taxon-uuid", "bar-taxon-uuid"] }
      ).once

      AlphaTaxonomy::TaxonLinker.new.run!
    end

    context "when the grouped mappings contain a taxon not present in the content store" do
      it "raises an error" do
        stub_import_file_mappings("/a-foo-content-item" => ["Foo Taxon"])
        stub_taxons_fetch([{ title: "Other taxon", content_id: "irrelevant" }])

        expect { AlphaTaxonomy::TaxonLinker.new.run! }.to raise_error(
          AlphaTaxonomy::TaxonLinker::TaxonNotInContentStoreError
        )
      end
    end

    context "when the target content_item is not found by the lookup" do
      before do
        stub_import_file_mappings("/a-foo-content-item" => ["Foo Taxon"], "/invalid-content-item" => ["Foo Taxon"])
        stub_taxons_fetch([{ title: "Foo Taxon", content_id: "foo-taxon-uuid" }])
        stub_content_item_lookup(base_path: "/a-foo-content-item", content_id: "foo-item-uuid")

        invalid_lookup = double(valid?: false, errors: { base_path: "something went wrong" })
        allow(ContentLookupForm).to receive(:new).with(base_path: "/invalid-content-item").and_return(invalid_lookup)
      end

      it "does not create a link and reports the error" do
        expect(Services.publishing_api).to receive(:put_links).with(
          "foo-item-uuid",
          links: { alpha_taxons: ["foo-taxon-uuid"] }
        ).once

        log_output = StringIO.new
        AlphaTaxonomy::TaxonLinker.new(logger: Logger.new(log_output)).run!
        log_output.rewind
        expect(log_output.read).to match(%r{Error fetching content id for /invalid-content-item: something went wrong})
      end
    end
  end
end
