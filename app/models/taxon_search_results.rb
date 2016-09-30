class TaxonSearchResults
  attr_reader :search_response

  def initialize(search_response)
    @search_response = search_response
  end

  def taxons
    @taxons ||=
      begin
        search_response['results'].map do |taxon_hash|
          Taxon.new(taxon_hash.slice(*Taxon::ATTRIBUTES))
        end
      end
  end

  def current_page
    search_response['current_page']
  end

  def total_pages
    search_response['pages']
  end

  def limit_value
    5
  end
end
