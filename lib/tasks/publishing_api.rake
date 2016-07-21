namespace :publishing_api do
  desc "Populates parent taxons with the links parent"
  task populate_parent_taxons: :environment do
    Taxonomy::TaxonFetcher.new.taxons.each do |taxon|
      Rails.logger.info "Populating taxon parent for #{taxon['title']}"
      Taxonomy::PopulateParentTaxons.run(content_id: taxon['content_id'])
    end
  end
end
