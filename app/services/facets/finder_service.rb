module Facets
  class FinderService
    LINKED_FINDER_CONTENT_ID = "42ce66de-04f3-4192-bf31-8394538e0734".freeze

    def linked_finder_ids(facet_group_content_id)
      Rails.cache.fetch("FinderLinksService/linked_finder_ids", expires_in: 4.hours) do
        finders_for_facet_group(facet_group_content_id).map { |f| f["content_id"] }
      end
    end

  private

    def finders_for_facet_group(facet_group_content_id)
      publishing_api.get_linked(facet_group_content_id).to_hash["body"]
    end

    def finder_links(content_id)
      @finder_links ||= publishing_api.get_links(content_id)
    end

    def publishing_api
      Services.publishing_api
    end
  end
end
