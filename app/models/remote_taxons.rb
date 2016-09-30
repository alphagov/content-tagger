class RemoteTaxons
  # TODO: deprecate this method in favour of search.
  def all
    @taxons ||=
      begin
        raw_taxons = taxon_content_items(page: nil, per_page: nil, query: nil)
        raw_taxons['results'].map do |taxon_hash|
          Taxon.new(taxon_hash.slice(*Taxon::ATTRIBUTES))
        end
      end
  end

  def search(page: 1, per_page: 50, query: '')
    TaxonSearchResults.new(
      taxon_content_items(page: page, per_page: per_page, query: query)
    )
  end

  # TODO: replace all with another method.
  def parents_for_taxon(taxon_child)
    all.select do |taxon|
      taxon_child.parent_taxons.include?(taxon.content_id)
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
