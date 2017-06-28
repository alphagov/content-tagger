namespace :taxonomy do
  desc "Publish taxons for worldwide taxonomy"
  task publish_taxons_for_worldwide_taxonomy: :environment do
    def all_taxons
      Services
        .publishing_api
        .get_content_items(
          document_type: 'taxon',
          per_page: 5000,
        ).to_h["results"]
    end

    world_taxons = all_taxons.select { |t| t["base_path"].starts_with?("/world") }
    world_taxons.each do |taxon|
      begin
        Services.publishing_api.publish(taxon["content_id"], "major")
      rescue => e
        puts "Error: #{e.message}"
      end
    end
  end
end
