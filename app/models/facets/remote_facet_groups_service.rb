module Facets
  class RemoteFacetGroupsService
    def find_all
      facet_group_content_items.to_hash["results"]
    end

    def find(content_id)
      expanded_facet_group(content_id).to_hash
    end

  private

    # Returns a facet group from the publishing API.
    def facet_group_content_items(query = '', states = %w(published))
      Services
        .publishing_api_with_long_timeout
        .get_content_items(
          document_type: 'facet_group',
          order: '-public_updated_at',
          q: query || '',
          search_in: %i[title],
          page: 1,
          per_page: 50,
          states: states,
        )
    end

    def expanded_facet_group(content_id)
      Services.publishing_api_with_long_timeout.get_expanded_links(content_id)
    end
  end
end
