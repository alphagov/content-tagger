require "gds_api/test_helpers/content_store"

RSpec.describe Metrics::ContentDistributionMetrics do
  include ::GdsApi::TestHelpers::ContentStore

  let(:registry) { Prometheus::Client::Registry.new }
  let(:metrics) { described_class.new(registry) }

  describe "#level_taggings" do
    before do
      stub_content_store_has_item("/", root_taxon.to_json, draft: true)
      stub_content_store_has_item("/taxons/root_taxon", child_taxons.to_json, draft: true)

      allow(Services.search_api).to receive(:search_enum).with(include(filter_taxons: %w[root_id]))
                                    .and_return content_items_enum(5)
      allow(Services.search_api).to receive(:search_enum).with(include(filter_taxons: %w[first_level_id]))
                                    .and_return content_items_enum(12)
      allow(Services.search_api).to receive(:search_enum).with(include(filter_taxons: %w[second_level_id_1 second_level_id_2]))
                                    .and_return content_items_enum(3)
    end

    it "calls gauges with number of content tagged to each level" do
      described_class.new(registry).count_content_per_level

      expect(registry.get(:content_distribution).values).to eq({
        { level: "1" } => 5.0,
        { level: "2" } => 12.0,
        { level: "3" } => 3.0,
      })
    end

    it "calls gauges with the average tagging depth" do
      described_class.new(registry).average_tagging_depth

      expect(registry.get(:average_tagging_depth).values).to eq({ {} => 1.9 })
    end

    def content_items_enum(elements)
      Array.new(elements) { { "content_id" => SecureRandom.uuid } }.to_enum
    end

    def root_taxon
      {
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/taxons/root_taxon",
            },
          ],
        },
      }
    end

    def child_taxons
      {
        "content_id" => "root_id",
        "links" => {
          "child_taxons" => [
            {
              "content_id" => "first_level_id",
              "links" => {
                "child_taxons" => [
                  {
                    "content_id" => "second_level_id_1",
                    "links" => {},
                  },
                  {
                    "content_id" => "second_level_id_2",
                    "links" => {},
                  },
                ],
              },
            },
          ],
        },
      }
    end
  end
end
