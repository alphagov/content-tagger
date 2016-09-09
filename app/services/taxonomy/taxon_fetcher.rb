module Taxonomy
  class TaxonFetcher
    def taxons
      @taxons ||= taxon_list.sort_by(&:title)
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

  private

    def taxon_list
      taxon_content_items.map do |taxon_hash|
        Taxon.new(taxon_hash.slice(*Taxon::ATTRIBUTES))
      end
    end

    def taxon_content_items
      Services
        .publishing_api
        .get_content_items(document_type: 'taxon')['results']
    end
  end
end
