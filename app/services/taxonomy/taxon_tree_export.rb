module Taxonomy
  class TaxonTreeExport
    attr_reader :taxon_content_id

    def initialize(content_id)
      @taxon_content_id = content_id
    end

    def expanded_taxon
      top_taxon = content_struct(taxon_content_id)
      Taxonomy::ExpandedTaxonomy.new(top_taxon.content_id)
    end

    def flatten_taxonomy(taxon)
      flattened_taxonomy = [convert_to_content_item(taxon)]

      if taxon.children
        taxon.children.each do |child_taxon|
          flattened_taxonomy += flatten_taxonomy(child_taxon)
        end
      end

      flattened_taxonomy
    end

    def convert_to_content_item(taxon, recursion_direction = nil)
      taxon_content = content_struct(taxon.content_id)

      content_item = {
        base_path: taxon.base_path,
        content_id: taxon.content_id,
        title: taxon.title,
        description: taxon_content.description,
        document_type: 'taxon',
        publishing_app: 'content-tagger',
        rendering_app: 'collections',
        schema_name: 'taxon',
        user_journey_document_supertype: 'finding',
        links: {},
      }

      unless recursion_direction == :parent
        content_item[:links][:child_taxons] = taxon.children.map { |child| convert_to_content_item(child, :child) }
      end
      unless recursion_direction == :child
        if taxon.parent
          content_item[:links][:parent_taxons] = [convert_to_content_item(taxon.parent, :parent)]
        end
      end

      content_item
    end

  private

    def content_struct(content_id)
      OpenStruct.new(Services.publishing_api.get_content(content_id).to_h)
    end
  end
end
