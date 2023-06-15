namespace :taxonomy do
  desc <<-DESC
    Removes legacy_taxons from a taxon if it exists on the links of that taxon.
  DESC
  task remove_legacy_taxon_links: :environment do |_, _args|
    file = File.open("lib/tasks/taxonomy/temp_mapped_taxons.txt")
    content_ids_of_mapped_taxons = file.readlines.map(&:chomp)
    taxons_updated_count = 0

    content_ids_of_mapped_taxons.each do |content_id|
      links_response = Services.publishing_api.get_links(content_id)
      next unless links_response["links"].key?("legacy_taxons")

      taxons_updated_count += 1
      puts "removing legacy taxons for content id #{content_id}"
      Services.publishing_api.patch_links(content_id, links: { legacy_taxons: [] })
    end

    puts "updated #{taxons_updated_count} taxons to remove legacy taxon links"
  end
end
