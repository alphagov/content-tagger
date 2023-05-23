module Metrics
  RSpec.describe ContentCoverageMetrics do
    let(:registry) { Prometheus::Client::Registry.new }
    let(:metrics) { described_class.new(registry) }

    describe "#record_all" do
      before do
        denylist = %w[taxon redirect]
        allow(Tagging)
          .to receive(:denylisted_document_types).and_return(denylist)

        stub_request(:get, "#{Plek.find('search-api')}/search.json")
          .with(
            query: {
              count: 0,
              debug: "include_withdrawn",
            },
          )
          .to_return(body: JSON.dump(total: 1000))

        stub_request(:get, "#{Plek.find('search-api')}/search.json")
          .with(
            query: {
              count: 0,
              debug: "include_withdrawn",
              reject_content_store_document_type: denylist,
            },
          ).to_return(body: JSON.dump(total: 500))

        level_one_taxons = FactoryBot.build_list(:linkable_taxon_hash, 2)

        stub_request(:get, "#{Plek.find('search-api')}/search.json")
          .with(
            query: {
              count: 0,
              debug: "include_withdrawn",
              filter_part_of_taxonomy_tree: level_one_taxons.map { |x| x[:content_id] },
              reject_content_store_document_type: denylist,
            },
          ).to_return(body: JSON.dump(total: 400))

        stub_publishing_api_has_expanded_links({
          content_id: GovukTaxonomy::ROOT_CONTENT_ID,
          expanded_links: {
            level_one_taxons:,
          },
        })
        stub_publishing_api_has_expanded_links(
          {
            content_id: GovukTaxonomy::ROOT_CONTENT_ID,
            expanded_links: {
              level_one_taxons: [],
            },
          },
          with_drafts: false,
        )
      end

      it "sends the correct values to statsd" do
        described_class.new(registry).record_all

        expect(registry.get(:all_govuk_items).values).to eq({ {} => 1000.0 })
        expect(registry.get(:items_in_scope).values).to eq({ {} => 500.0 })
        expect(registry.get(:tagged_items_in_scope).values).to eq({ {} => 400.0 })
      end
    end
  end
end
