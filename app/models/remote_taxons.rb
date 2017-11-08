# TODO: Split this up and move it into the BulkTagging & Taxonomy namespaces.
class RemoteTaxons
  def search(page: 1, per_page: 50, query: '', states: ['published'])
    BulkTagging::TaxonSearchResults.new(
      taxon_content_items(page: page, per_page: per_page, query: query, states: states)
    )
  end

  def parent_for_taxon(taxon_child)
    Taxonomy::BuildTaxon.call(content_id: taxon_child.parent)
  end

private

  # Return a list of taxons from the publishing API with links included.
  # Does not include the details hash of each taxon.
  def taxon_content_items(page:, per_page:, query:, states:)
    Services
      .publishing_api
      .get_content_items(
        document_type: 'taxon',
        order: '-public_updated_at',
        q: query || '',
        search_in: %i[title base_path details.internal_name],
        page: page || 1,
        per_page: per_page || 50,
        states: states || [],
      )
  end
end
