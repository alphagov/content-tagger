require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonLinkDeleter do
  describe "#run!" do
    context "given some taxon base paths that are linked to content" do
      before do
        publishing_api_has_lookups(
          "/foo-taxon" => "foo-taxon-uuid",
          "/bar-taxon" => "bar-taxon-uuid",
        )
        allow(Services.publishing_api).to receive(:get_linked_items)
          .with("foo-taxon-uuid", link_type: 'alpha_taxons', fields: %w(content_id base_path))
          .and_return([{ "content_id" => "linked-item-1", "base_path" => "/linked-item-1" }])
        allow(Services.publishing_api).to receive(:get_linked_items)
          .with("bar-taxon-uuid", link_type: 'alpha_taxons', fields: %w(content_id base_path))
          .and_return([
            { "content_id" => "linked-item-2", "base_path" => "/linked_item-2" },
            { "content_id" => "linked-item-3", "base_path" => "/linked_item-3" }
          ])
      end

      it "deletes the taxon links of any content items tagged to the provided taxons" do
        expect(Services.publishing_api).to receive(:patch_links).with("linked-item-1", links: { alpha_taxons: [] })
        expect(Services.publishing_api).to receive(:patch_links).with("linked-item-2", links: { alpha_taxons: [] })
        expect(Services.publishing_api).to receive(:patch_links).with("linked-item-3", links: { alpha_taxons: [] })

        AlphaTaxonomy::TaxonLinkDeleter.new(
          logger: Logger.new(StringIO.new), base_paths: ["/foo-taxon", "/bar-taxon"]
        ).run!
      end
    end

    context "given a taxon base path that isn't linked to anything" do
      before do
        publishing_api_has_lookups("/foo-taxon" => "foo-taxon-uuid")
        allow(Services.publishing_api).to receive(:get_linked_items)
          .with("foo-taxon-uuid", link_type: 'alpha_taxons', fields: %w(content_id base_path))
          .and_return([])
      end

      it "does nothing" do
        expect(Services.publishing_api).to_not receive(:patch_links)

        AlphaTaxonomy::TaxonLinkDeleter.new(
          logger: Logger.new(StringIO.new), base_paths: ["/foo-taxon"]
        ).run!
      end
    end
  end
end
