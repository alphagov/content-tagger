require 'gds_api/rummager'
require 'csv'

namespace :taxonomy do
  namespace :analysis do
    desc "Produces a CSV list of content items under a root taxon ID, and the taxons they are tagged to"
    task :taxons_tagged_to_content, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)

      results_per_page = 1000
      page = 0
      content_items = []
      loop do
        results = GdsApi::Rummager.new(Plek.find('rummager')).search(
          filter_part_of_taxonomy_tree: root_taxon_id,
          fields: %w(link taxons content_id}),
          start: page * results_per_page,
          count: results_per_page,
        )['results']

        break if results.empty?

        content_items += results
        page += 1
      end

      puts %w(content_id, base_path, number_of_taxons).to_csv

      content_items.each do |content_item|
        csv_row = [
          content_item['content_id'],
          content_item['link'],
          content_item['taxons'].length,
        ]

        content_item['taxons'].each { |taxon_id| csv_row << taxon_id }

        puts csv_row.to_csv
      end
    end
  end
end
