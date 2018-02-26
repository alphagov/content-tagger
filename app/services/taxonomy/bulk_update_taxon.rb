module Taxonomy
  class BulkUpdateTaxon
    def initialize(root_taxon_content_id, attributes)
      @root_taxon_content_id = root_taxon_content_id
      @attributes = attributes
    end

    def bulk_update
      nested_tree.each do |taxon|
        UpdateTaxonWorker.perform_async(taxon.content_id, update_payload(taxon))
      end
    end

  private

    def nested_tree
      GovukTaxonomyHelpers::LinkedContentItem
        .from_content_id(
          content_id: @root_taxon_content_id,
          publishing_api: Services.publishing_api
        )
    end

    def update_payload(taxon)
      {
        document_type: 'taxon',
        publishing_app: 'content-tagger',
        schema_name: 'taxon',
        title: taxon.title,
        phase: @attributes.fetch(:phase),
      }
    end
  end
end
