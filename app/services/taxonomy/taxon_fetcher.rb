module Taxonomy
  class TaxonFetcher
    # Return a list of taxons from the publishing API with links included.
    def taxons
      @taxons ||=
        Services.publishing_api.get_linkables(document_type: 'taxon')
          .map { |taxon_hash| Taxon.new(taxon_hash) }
          .sort_by(&:title)
    end

    def taxon_content_ids
      taxons.map(&:content_id)
    end

    def taxons_for_select
      taxons.map { |taxon| [taxon.title, taxon.content_id] }
    end

    def parents_for_taxon(taxon_child)
      taxons.select do |taxon|
        taxon_child.parent_taxons.include?(taxon.content_id)
      end
    end
  end
end
