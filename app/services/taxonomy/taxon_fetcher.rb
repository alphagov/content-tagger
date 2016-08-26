module Taxonomy
  class TaxonFetcher
    # Return a list of taxons from the publishing API with links included.
    def taxons
      @taxons ||=
        Services.publishing_api.get_linkables(document_type: 'taxon')
          .sort_by { |taxon| taxon["title"] }
    end

    def taxon_content_ids
      taxons.map { |taxon| taxon['content_id'] }
    end

    def taxons_for_select
      taxons.map { |taxon| [taxon['title'], taxon['content_id']] }
    end

    def parents_for_taxon(taxon)
      taxons.select do |taxon_hash|
        taxon.parent_taxons.include?(taxon_hash['content_id'])
      end
    end
  end
end
