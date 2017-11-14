module Taxonomy
  class BulkUpdateTaxon
    def initialize(root_taxon_content_id)
      @root_taxon_content_id = root_taxon_content_id
    end

    def self.call(root_taxon_content_id)
      new(root_taxon_content_id).bulk_publish
    end

    def bulk_publish
      linked_content_item = GovukTaxonomyHelpers::LinkedContentItem.from_content_id(content_id: @root_taxon_content_id,
                                                                                    publishing_api: Services.publishing_api)
      linked_content_item.each do |taxon|
        PublishTaxonWorker.perform_async(taxon)
      end
    end
  end
end
