require 'rails_helper'

module Metrics
  RSpec.describe ContentDistributionMetrics do
    describe '#level_taggings' do
      before :each do
        allow(Services.content_store).to receive(:content_item).with('/').and_return root_taxon
        allow(Services.content_store).to receive(:content_item).with('/taxons/root_taxon')
                                           .and_return child_taxons

        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: ['root_id']))
                                      .and_return content_items_enum(5)
        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: ['first_level_id']))
                                      .and_return content_items_enum(12)
        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: %w[second_level_id_1 second_level_id_2]))
                                      .and_return content_items_enum(3)
      end
      it 'calls gauges with number of content tagged to each level' do
        expect(Metrics.statsd).to receive(:gauge).with("level_1.content_tagged", 5)
        expect(Metrics.statsd).to receive(:gauge).with("level_1.level", 1)
        expect(Metrics.statsd).to receive(:gauge).with("level_2.content_tagged", 12)
        expect(Metrics.statsd).to receive(:gauge).with("level_2.level", 2)
        expect(Metrics.statsd).to receive(:gauge).with("level_3.content_tagged", 3)
        expect(Metrics.statsd).to receive(:gauge).with("level_3.level", 3)

        ContentDistributionMetrics.new.count_content_per_level
      end
      it 'calls gauges with the average tagging depth' do
        expect(Metrics.statsd).to receive(:gauge).with("average_tagging_depth", 1.9)

        ContentDistributionMetrics.new.average_tagging_depth
      end

      def content_items_enum(elements)
        (Array.new(elements) { { 'content_id' => SecureRandom.uuid } }).to_enum
      end

      def root_taxon
        {
          "links" => {
            "root_taxons" => [
              {
                "base_path" => "/taxons/root_taxon"
              }
            ]
          }
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
                      "links" => {}
                    },
                    {
                      "content_id" => "second_level_id_2",
                      "links" => {}
                    }
                  ]
                }
              }
            ]
          }
        }
      end
    end
  end
end
