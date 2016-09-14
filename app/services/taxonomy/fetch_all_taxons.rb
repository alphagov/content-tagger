module Taxonomy
  class FetchAllTaxons
    # Return a list of taxons from the publishing API with links included.
    # Does not include the details hash of each taxon.
    def taxons
      @taxons ||=
        begin
          taxon_content_items.map do |taxon_hash|
            Taxon.new(taxon_hash.slice(*Taxon::ATTRIBUTES))
          end
        end
    end

    def taxon_content_ids
      taxons.map(&:content_id)
    end

    def parents_for_taxon(taxon_child)
      taxons.select do |taxon|
        taxon_child.parent_taxons.include?(taxon.content_id)
      end
    end

  private

    def taxon_content_items
      Services
        .publishing_api
        .get_content_items(
          document_type: 'taxon',
          order: '-public_updated_at'
        )['results']
    end
  end
end
