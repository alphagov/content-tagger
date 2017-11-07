module LegacyTaxonomy
  class TagContent
    include Sidekiq::Worker

    def perform(taxon_content_id, taggable_content_id)
      links = Client::PublishingApi.get_links(taggable_content_id)
      previous_version = links['version'] || 0
      taxons = links.dig('links', 'taxons') || []
      taxons << taxon_content_id

      Client::PublishingApi.patch_links(taggable_content_id,
                                        links: { taxons: taxons.uniq },
                                        previous_version: previous_version,
                                        bulk_publishing: true)
    rescue GdsApi::HTTPNotFound
      puts "404 Taggable Not Found"
    end
  end
end
