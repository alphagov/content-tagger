module BulkTagging
  RSpec.describe Search do
    include ContentItemHelper

    before do
      stub_publishing_api_has_content(
        [basic_content_item("A content item")],
        q: "tax",
        page: 1,
        document_type: "taxon",
        fields: %i[content_id document_type title base_path],
        search_in: %i[title base_path details.internal_name],
      )
    end

    it "returns an instance of SearchResponse" do
      search = described_class.new(query: "tax", page: 1, document_type: "taxon")

      expect(search.call).to be_a(SearchResponse)
    end
  end
end
