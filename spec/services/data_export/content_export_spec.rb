module DataExport
  RSpec.describe ContentExport do
    describe "#get_content" do
      it "returns empty hash if there is no content for the base path" do
        allow(Services.content_store).to receive(:content_item).with("/base_path").and_raise GdsApi::ContentStore::ItemNotFound.new(404)
        expect(described_class.new.get_content("/base_path")).to eq({})
      end

      it "returns simple content" do
        allow(Services.content_store).to receive(:content_item).with("/base_path").and_return content_no_taxon
        expect(described_class.new.get_content("/base_path", base_fields: %w[base_path content_id]))
          .to eq("base_path" => "/base_path", "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f")
      end

      it "returns taxons" do
        allow(Services.content_store).to receive(:content_item).with("/base_path").and_return content_with_taxons
        expect(described_class.new.get_content("/base_path", taxon_fields: %w[content_id])["taxons"])
          .to eq([{ "content_id" => "237b2e72-c465-42fe-9293-8b6af21713c0" },
                  { "content_id" => "8da62d85-47c0-42df-94c4-eaaeac329671" }])
      end

      it "returns the primary publishing organistations" do
        allow(Services.content_store).to receive(:content_item).with("/base_path").and_return content_with_ppo
        expect(described_class.new.get_content("/base_path", ppo_fields: %w[title])["primary_publishing_organisation"])
          .to eq("title" => "title1")
      end

      def content_with_taxons
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {
            "taxons" => [{ "content_id" => "237b2e72-c465-42fe-9293-8b6af21713c0" },
                         { "content_id" => "8da62d85-47c0-42df-94c4-eaaeac329671" }],
          },
        }
      end

      def content_with_ppo
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {
            "primary_publishing_organisation" => [
              { "title" => "title1" },
            ],
          },
        }
      end

      def content_no_taxon
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {},
        }
      end
    end

    describe "#content_links_enum" do
      it "returns content links in an enumerator" do
        stub_request(:get, Regexp.new(Plek.find("search-api")))
          .to_return(body: { "results" => [{ "link" => "/first/path" }, { "link" => "/second/path" }] }.to_json)
        expect(described_class.new.content_links_enum.to_a).to eq(["/first/path", "/second/path"])
      end
    end

    describe "#denylisted_content_stats" do
      it "returns the number of documents in that were denylisted in content export" do
        result_hash = {
          "aggregates" => {
            "content_store_document_type" => {
              "options" => [
                {
                  "value" => {
                    "slug" => "taxon",
                  },
                  "documents" => 1,
                },
                {
                  "value" => {
                    "slug" => "news_story",
                  },
                  "documents" => 2,
                },
                {
                  "value" => {
                    "slug" => "redirect",
                  },
                  "documents" => 3,
                },
              ],
            },
          },
        }
        stub_request(:get, Regexp.new(Plek.find("search-api")))
          .with(query: hash_including("aggregate_content_store_document_type" => "10000"))
          .to_return(body: result_hash.to_json)

        expect(described_class.new.denylisted_content_stats(%w[taxon redirect]))
          .to eq([{ document_type: "redirect", count: 3 }, { document_type: "taxon", count: 1 }])
      end
    end
  end
end
