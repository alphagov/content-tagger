module Taxonomy
  class BulkUpdateTaxon
    def initialize(root_taxon_content_id, attributes)
      @root_taxon_content_id = root_taxon_content_id
      @attributes = attributes
    end

    def bulk_update
      nested_tree.each do |taxon|
        UpdateTaxonWorker.perform_async(taxon.content_id, @attributes.stringify_keys)
      end
    end

  private

    def nested_tree
      LinkedContentItem.from_content_id(
        content_id: @root_taxon_content_id,
        publishing_api: Services.publishing_api,
      )
    end
  end
end
