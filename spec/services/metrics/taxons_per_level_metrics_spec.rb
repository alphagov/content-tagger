require "rails_helper"
require "gds_api/test_helpers/content_store"

include ::GdsApi::TestHelpers::ContentStore

module Metrics
  RSpec.describe TaxonsPerLevelMetrics do
    describe "#count_taxons_per_level" do
      before do
        content_store_has_item("/", root_taxon.to_json, draft: true)
        content_store_has_item("/taxons/level_one_taxon", multi_level_child_taxons.to_json, draft: true)
      end
      it "sends the correct values to statsd" do
        expect(Metrics.statsd).to receive(:gauge)
                                      .with("level_1.number_of_taxons", 1)
        expect(Metrics.statsd).to receive(:gauge)
                                      .with("level_2.number_of_taxons", 1)
        expect(Metrics.statsd).to receive(:gauge)
                                      .with("level_3.number_of_taxons", 2)
        TaxonsPerLevelMetrics.new.count_taxons_per_level
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
end
