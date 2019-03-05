require 'rails_helper'

module Metrics
  RSpec.describe ContentCoverageMetrics do
    describe '#record_all' do
      before do
        blacklist = %w[taxon redirect]
        allow(Tagging)
          .to receive(:blacklisted_document_types).and_return(blacklist)

        stub_request(:get, "#{Plek.find('search')}/search.json")
          .with(
            query: {
              count: 0,
              debug: 'include_withdrawn'
            }
          )
          .to_return(body: JSON.dump(total: 1000))

        stub_request(:get, "#{Plek.find('search')}/search.json")
          .with(
            query: {
              count: 0,
              debug: 'include_withdrawn',
              reject_content_store_document_type: blacklist
            }
          ).to_return(body: JSON.dump(total: 500))

        level_one_taxons = FactoryBot.build_list(:linkable_taxon_hash, 2)

        stub_request(:get, "#{Plek.find('search')}/search.json")
          .with(
            query: {
              count: 0,
              debug: 'include_withdrawn',
              filter_part_of_taxonomy_tree: level_one_taxons.map { |x| x[:content_id] },
              reject_content_store_document_type: blacklist
            }
          ).to_return(body: JSON.dump(total: 400))

        publishing_api_has_expanded_links(
          content_id: GovukTaxonomy::ROOT_CONTENT_ID,
          expanded_links: {
            level_one_taxons: level_one_taxons
          }
        )
        publishing_api_has_expanded_links(
          {
            content_id: GovukTaxonomy::ROOT_CONTENT_ID,
            expanded_links: {
              level_one_taxons: [],
            }
          },
          with_drafts: false
        )
      end

      it "sends the correct values to statsd" do
        allow(Metrics.statsd).to receive(:gauge)

        Metrics::ContentCoverageMetrics.new.record_all

        expect(Metrics.statsd).to have_received(:gauge)
                                    .with("all_govuk_items", 1000)

        expect(Metrics.statsd).to have_received(:gauge)
                                    .with("items_in_scope", 500)

        expect(Metrics.statsd).to have_received(:gauge)
                                    .with("tagged_items_in_scope", 400)

        expect(Metrics.statsd).to have_received(:gauge)
                                    .with("untagged_items_in_scope", 100)
      end
    end
  end
end
