require 'rails_helper'

module Metrics
  RSpec.describe ContentPerLevelMetric do
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
        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_1", 5)
        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_2", 12)
        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_3", 3)

        ContentPerLevelMetric.new.count_content_per_level
      end
      it 'calls gauges with the average tagging depth' do
        expect(Services.statsd).to receive(:gauge).with("average_tagging_depth", 1.9)

        ContentPerLevelMetric.new.average_tagging_depth
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
