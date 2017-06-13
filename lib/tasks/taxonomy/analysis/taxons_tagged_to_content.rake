require 'gds_api/rummager'
require 'csv'

namespace :taxonomy do
  namespace :analysis do
    desc "Produces a CSV list of links under a root taxon ID, and the base paths they are tagged to"
    task :taxons_tagged_to_content, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)

      results_per_page = 1000
      page = 0
      content_items = []
      loop do
        results = GdsApi::Rummager.new(Plek.find('rummager')).search(
          filter_part_of_taxonomy_tree: root_taxon_id,
          fields: %w(link taxons),
          start: page * results_per_page,
          count: results_per_page,
        )['results']

        break if results.empty?

        content_items += results
        page += 1
      end

      content_items.each do |item|
        details = []
        item["taxons"].each do |taxon|
          resp = Services.publishing_api.get_content(taxon)
          details << resp["base_path"]
        end
        item["base_paths"] = details
      end

      puts %w(Link Number_of_taxons Base_path_1 Taxon_id_1 Base_path_2
        Taxon_id_2 Base_path_3 Taxon_id_3).to_csv

      content_items.each do |content_item|
        csv_row = [
          content_item['link'],
          content_item['taxons'].length,
        ]

        max = [content_item['base_paths'].length, content_item['taxons'].length].max

        for i in 0...max
          content_item['base_paths'][i].nil? ? nil
            : csv_row.push(content_item['base_paths'][i])

          content_item['taxons'][i].nil? ? nil
            : csv_row.push(content_item['taxons'][i])
        end
        puts csv_row.to_csv
      end
    end
  end
end
