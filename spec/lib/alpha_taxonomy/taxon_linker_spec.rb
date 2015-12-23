require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonLinker do
  describe "#run!" do
    def stub_taxon_fetch(title:, content_id:)
      allow(Services.content_store).to receive(:content_item!).with(
        AlphaTaxonomy::TaxonPresenter.new(title: title).base_path
      ).and_return("content_id" => content_id)
    end

    def stub_content_item_fetch(base_path:, content_id:)
      allow(Services.content_store).to receive(:content_item!).with(
        base_path
      ).and_return("content_id" => content_id)
    end

    it "creates taxon links based on the grouped mappings" do
      import_file = AlphaTaxonomy::ImportFile.new
      allow(import_file).to receive(:grouped_mappings).and_return(
        "/a-foo-content-item" => ["Foo Taxon"],
        "/a-foo-bar-content-item" => ["Foo Taxon", "Bar Taxon"]
      )
      allow(AlphaTaxonomy::ImportFile).to receive(:new).and_return(import_file)

      stub_taxon_fetch(title: "Foo Taxon", content_id: "foo-taxon-uuid")
      stub_taxon_fetch(title: "Bar Taxon", content_id: "bar-taxon-uuid")
      stub_content_item_fetch(base_path: "/a-foo-content-item", content_id: "foo-item-uuid")
      stub_content_item_fetch(base_path: "/a-foo-bar-content-item", content_id: "foo-bar-item-uuid")

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
  end
end
