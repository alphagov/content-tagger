module LegacyTaxonomy
  class TaxonomyPublisher
    include Sidekiq::Worker

    def perform(taxon_data_yml, parent_taxon_id = nil, publish = false)
      taxon_data = Yamlizer.deserialize(taxon_data_yml)
      content_id = taxon_data.content_id

      Client::PublishingApi.put_content(content_id, taxon_for_publishing_api(taxon_data))
      Client::PublishingApi.publish(content_id) if publish

      if parent_taxon_id
        Client::PublishingApi.patch_links(content_id, links: { parent_taxons: [parent_taxon_id] })
      end

      taxon_data.tagged_pages
        .map { |page| page['content_id'] }
        .select(&:present?)
        .each do |taggable_content_id|
          TagContent.perform_async(content_id, taggable_content_id)
        end

      taxon_data.child_taxons.each do |child_taxon|
        child_taxon_yml = Yamlizer.serialize(child_taxon)
        TaxonomyPublisher.perform_async(child_taxon_yml, content_id)
      end
    end

    def taxon_for_publishing_api(taxon)
      taxon_attrs = taxon.hash_for_publishing_api
      Taxonomy::BuildTaxonPayload.call(taxon: Taxon.new(taxon_attrs))
    end
  end
end
