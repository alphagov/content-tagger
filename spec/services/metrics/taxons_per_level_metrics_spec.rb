require "gds_api/test_helpers/content_store"

RSpec.describe Metrics::TaxonsPerLevelMetrics do
  include ::GdsApi::TestHelpers::ContentStore

  let(:registry) { Prometheus::Client::Registry.new }
  let(:metrics) { described_class.new(registry) }

  describe "#count_taxons_per_level" do
    before do
      stub_content_store_has_item("/", root_taxon.to_json, draft: true)
      stub_content_store_has_item("/taxons/level_one_taxon", multi_level_child_taxons.to_json, draft: true)
    end

    it "sends the correct values to statsd" do
      described_class.new(registry).count_taxons_per_level

      expect(registry.get(:number_of_taxons).values).to eq({
        { level: "1" } => 1.0,
        { level: "2" } => 1.0,
        { level: "3" } => 2.0,
      })
    end

    def multi_level_child_taxons
      {
        "base_path" => "/taxons/root_taxon",
        "content_id" => "rrrr",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/root_taxon/taxon_a",
              "content_id" => "aaaa",
              "links" => {
                "child_taxons" => [
                  {
                    "base_path" => "/root_taxon/taxon_1",
                    "content_id" => "aaaa_1111",
                    "links" => {},
                  },
                  {
                    "base_path" => "/root_taxon/taxon_2",
                    "content_id" => "aaaa_2222",
                    "links" => {},
                  },
                ],
              },
            },
          ],
        },
      }
    end

    def root_taxon
      {
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/taxons/level_one_taxon",
              "content_id" => "rrrr",
            },
          ],
        },
      }
    end
  end
end
