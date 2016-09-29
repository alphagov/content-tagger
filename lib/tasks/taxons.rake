namespace :taxons do
  desc 'Clear the parent link of existing Taxons'
  task clear_parent: :environment do
    taxons = Services.publishing_api.get_linkables(document_type: 'taxon')

    taxons.each do |taxon|
      Rails.logger.info "Clearing parent link for #{taxon['title']}"

      Taxonomy::ClearParentLink.call(taxon['content_id'])
    end
  end
end
