module Facets
  class RemoteFacetGroupsService
    # TODO: There's currently only one facet group defined, and we don't yet
    # have a sophisticated enough UI to 'choose' different facet groups so
    # defining the group here means we can default to the only published group
    # for now. This will save on an additional call to the publishing API.
    # Once we have multiple groups and a UI to handle choosing a group to use
    # when tagging content, this constant can be removed.
    PUBLISHED_FACET_GROUPS = %w[52435175-82ed-4a04-adef-74c0199d0f46].freeze

    def find_all
      facet_group_content_items.to_hash["results"]
    end

    def find(content_id)
      expanded_facet_group(content_id).to_hash
    end

  private

    # Returns a facet group from the publishing API.
    def facet_group_content_items(query = '', states = %w[published])
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
