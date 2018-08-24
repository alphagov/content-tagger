require 'gds_api/base'
namespace :content do
  desc "Export mappings from policy areas to taxons"
  task export_legacy_mappings: :environment do
    policy_areas = Services.rummager.search_enum({ filter_format: 'topic',
                                                   fields: %w[link title] }, page_size: 100)
    CSV.open('tmp/policy_area_mappings.csv', "wb", headers: %w[policy_area taxon taxon taxon], write_headers: true) do |csv|
      policy_areas.each do |policy_area|
        content = Services.content_store.content_item(policy_area['link'])
        taxons = content.dig('links', 'topic_taxonomy_taxons') || []
        csv << (taxons.map { |taxon| taxon['base_path'] }.unshift policy_area['link'])
      end
    end
  end
end
