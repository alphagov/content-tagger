require 'rails_helper'

module Metrics
  RSpec.describe ContentPerLevelMetric do
    describe '#level_taggings' do
      it 'calls gauges' do
        allow(Services.content_store).to receive(:content_item).with('/').and_return root_taxon
        allow(Services.content_store).to receive(:content_item).with('/taxons/root_taxon')
                                           .and_return child_taxons

        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: ['root_id']))
                             .and_return content_items_enum(1)
        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: ['first_level_id']))
                             .and_return content_items_enum(2)
        allow(Services.rummager).to receive(:search_enum).with(include(filter_taxons: %w[second_level_id_1 second_level_id_2]))
                             .and_return content_items_enum(3)

        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_1", 1)
        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_2", 2)
        expect(Services.statsd).to receive(:gauge).with("content_tagged.level_3", 3)

        ContentPerLevelMetric.count_content_per_level
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
