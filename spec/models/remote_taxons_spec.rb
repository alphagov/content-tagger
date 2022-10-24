RSpec.describe RemoteTaxons do
  include ContentItemHelper
  include PublishingApiHelper

  describe "#search" do
    it "fetches taxons from the publishing api with pagination" do
      taxon1 = { title: "foo" }
      taxon2 = { title: "bar" }
      taxon3 = { title: "aha" }
      publishing_api_has_taxons(
        [taxon1, taxon2, taxon3],
        page: 2,
        per_page: 2,
      )

      result = described_class.new.search(page: 2, per_page: 2)

      expect(result).to be_a(BulkTagging::TaxonSearchResults)
      expect(result.taxons.length).to eq(1)
      taxon = result.taxons.first
      expect(taxon.title).to eq("aha")
    end

    it "is possible to search with a query string" do
      taxon1 = { title: "foo" }
      publishing_api_has_taxons(
        [taxon1],
        page: 1,
        per_page: 1,
        q: "foo",
      )
      result = described_class.new.search(
        page: 1,
        per_page: 1,
        query: "foo",
      )

      expect(result.taxons.length).to eq(1)
    end

    it "fetches deleted taxons from the publishing api with pagination" do
      taxon1 = { title: "foo" }
      taxon2 = { title: "bar" }
      taxon3 = { title: "aha" }
      publishing_api_has_deleted_taxons(
        [taxon1, taxon2, taxon3],
        page: 2,
        per_page: 2,
      )

      result = described_class.new.search(page: 2, per_page: 2, states: %w[unpublished])

      expect(result).to be_a(BulkTagging::TaxonSearchResults)
      expect(result.taxons.length).to eq(1)
      taxon = result.taxons.first
      expect(taxon.title).to eq("aha")
    end
  end

  describe "#parent_for_taxon" do
    let(:parent_taxon_id) { SecureRandom.uuid }
    let(:parent_taxon) do
      taxon_with_details(
        "foo",
        other_fields: {
          base_path: "/foo/1",
          content_id: parent_taxon_id,
        },
      )
    end

    let(:child_taxon) { instance_double(Taxon, parent_content_id: parent_taxon_id) }

    before do
      stub_publishing_api_has_item(parent_taxon)
      stub_publishing_api_has_expanded_links({ content_id: parent_taxon_id })
    end

    it "returns the parent taxon for a given taxon" do
      instance = described_class.new.parent_for_taxon(child_taxon)
      expect(instance).to have_attributes(
        base_path: parent_taxon[:base_path],
        content_id: parent_taxon[:content_id],
        title: parent_taxon[:title],
      )
    end
  end
end
