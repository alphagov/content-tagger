RSpec.describe BulkTagging::DocumentTypeTagger do
  include GdsApi::TestHelpers::PublishingApi

  let(:taxon_content_id) { "51ac4247-fd92-470a-a207-6b852a97f2db" }

  it "cannot find a taxon and raises an error" do
    stub_publishing_api_does_not_have_item(taxon_content_id)
    expect { described_class.call(taxon_content_id:, document_type: "document_type") }
            .to raise_error(GdsApi::HTTPNotFound, /not find content item with/)
  end

  context "when there is a taxon, some content and links" do
    before do
      stub_publishing_api_has_item(content_id: taxon_content_id)
      stub_publishing_api_has_content(
        [{ content_id: "c1" }, { content_id: "c2" }],
        page: 1,
        document_type: "document_type",
        fields: %w[content_id],
      )

      stub_publishing_api_has_links(
        content_id: "c1",
        links: {
          taxons: %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
        },
        version: 6,
      )
      stub_publishing_api_has_links(
        "content_id": "c2",
        "links": {},
        "version": 10,
      )
    end

    it "returns two error messages" do
      stub_any_publishing_api_patch_links.to_return(status: 404)

      expect(described_class.call(taxon_content_id:, document_type: "document_type").force)
        .to contain_exactly({ status: "error", message: /Response body/, content_id: "c1", new_taxons: [] }, { status: "error", message: /Response body/, content_id: "c2", new_taxons: [] })
    end

    it "tags two content items" do
      stub_any_publishing_api_patch_links

      expect(described_class.call(taxon_content_id:, document_type: "document_type").force)
        .to contain_exactly({ status: "success", message: "success", content_id: "c1", new_taxons: ["569a9ee5-c195-4b7f-b9dc-edc17a09113f", taxon_content_id] }, { status: "success", message: "success", content_id: "c2", new_taxons: [taxon_content_id] })

      assert_publishing_api_patch_links(
        "c1",
        links: { taxons: ["569a9ee5-c195-4b7f-b9dc-edc17a09113f", taxon_content_id] },
        previous_version: 6,
      )
      assert_publishing_api_patch_links(
        "c2",
        links: { taxons: [taxon_content_id] },
        previous_version: 10,
      )
    end
  end
end
