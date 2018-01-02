namespace :taxonomy do
  desc <<-DESC
    Copy the deprecated root_taxons to the new level_one_taxon<->root_taxon reverse link.
  DESC
  task sync_root_taxons: [:environment] do
    level_one_taxons = Services.publishing_api.get_links(GovukTaxonomy::ROOT_CONTENT_ID).dig('links', 'root_taxons')
    level_one_taxons.each do |level_one_taxon|
      puts "Adding Taxon: #{level_one_taxon}"
      Services.publishing_api.patch_links(level_one_taxon, links: { root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID] })
    end
  end
end
