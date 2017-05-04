namespace :taxonomy do
  desc "Promote a taxon to become a taxonomy root"
  task :promote_taxon_to_taxonomy_root, [:taxon_id] => :environment do |_, args|
    taxon_id = args.fetch(:taxon_id)
    homepage_content_id = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"

    puts "Promoting content with ID: #{taxon_id} to a taxonomic root node."

    begin
      homepage_links = Services.publishing_api.get_links(
        homepage_content_id
      )

      root_taxons = homepage_links['links'].fetch('root_taxons', [])
      root_taxons << taxon_id

      Services.publishing_api.patch_links(
        homepage_content_id,
        links: { root_taxons: root_taxons.uniq },
      )

      puts '✅  OK'
    rescue GdsApi::BaseError => e
      puts "❌  FAILURE #{e.code}"
      exit(1)
    end
  end
end
