module LegacyTaxonomy
  class MissingPagesFinder
    def find(taxonomies)
      index = LegacyTaxonomiesIndex.new(taxonomies)

      results = Client::PublishingApi.all_taxons_content_ids.map do |taxon_content_id|
        new_ids = Client::PublishingApi.content_ids_linked_to_taxon(taxon_content_id)
        legacy_taxon_ids = Client::PublishingApi.legacy_content_ids(taxon_content_id)
        legacy_ids = legacy_taxon_ids.flat_map do |legacy_id|
          index.tagged_pages(legacy_id).map { |l| l['content_id'] }
        end
        { taxon_content_id: taxon_content_id, missing_pages: (legacy_ids - new_ids) }
      end
      results.reject { |result| result[:missing_pages].empty? }
    end
  end
end
