class RemoteTaxons
  def search(page: 1, per_page: 50, query: '')
    TaxonSearchResults.new(
      taxon_content_items(page: page, per_page: per_page, query: query)
    )
  end

  def parents_for_taxon(taxon_child)
    taxon_child.parent_taxons.map do |parent_taxon_content_id|
      Taxonomy::BuildTaxon.call(content_id: parent_taxon_content_id)
    end
  end

private

  # Return a list of taxons from the publishing API with links included.
  # Does not include the details hash of each taxon.
  def taxon_content_items(page:, per_page:, query:)
    Services
      .publishing_api
      .get_content_items(
        document_type: 'taxon',
        order: '-public_updated_at',
        q: query || '',
        page: page || 1,
        per_page: per_page || 50
      )
  end
end
