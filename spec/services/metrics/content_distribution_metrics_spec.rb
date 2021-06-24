require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe Metrics::ContentDistributionMetrics do
  include ::GdsApi::TestHelpers::ContentStore

  describe "#level_taggings" do
    before :each do
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
      expect(Metrics.statsd).to receive(:gauge).with("level_1.content_tagged", 5)
      expect(Metrics.statsd).to receive(:gauge).with("level_1.level", 1)
      expect(Metrics.statsd).to receive(:gauge).with("level_2.content_tagged", 12)
      expect(Metrics.statsd).to receive(:gauge).with("level_2.level", 2)
      expect(Metrics.statsd).to receive(:gauge).with("level_3.content_tagged", 3)
      expect(Metrics.statsd).to receive(:gauge).with("level_3.level", 3)

      described_class.new.count_content_per_level
    end
    it "calls gauges with the average tagging depth" do
      expect(Metrics.statsd).to receive(:gauge).with("average_tagging_depth", 1.9)

      described_class.new.average_tagging_depth
    end

    def content_items_enum(elements)
      (Array.new(elements) { { "content_id" => SecureRandom.uuid } }).to_enum
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
