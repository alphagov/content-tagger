class TaxonSearchResults
  attr_reader :search_response

  def initialize(search_response)
    @search_response = search_response
  end

  def taxons
    @taxons ||=
      begin
        results = search_response['results'].map do |taxon_hash|
          next if taxon_hash['publication_state'] == 'unpublished'

          details = taxon_hash['details'] || {}
          Taxon.new(
            document_type: taxon_hash['document_type'],
            content_id: taxon_hash['content_id'],
            title: taxon_hash["title"],
            description: taxon_hash["description"],
            base_path: taxon_hash["base_path"],
            publication_state: taxon_hash['publication_state'],
            internal_name: details['internal_name'],
            notes_for_editors: details['notes_for_editors']
          )
        end

        results.compact
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
