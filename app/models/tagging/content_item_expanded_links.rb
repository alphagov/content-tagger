module Tagging
  class ContentItemExpandedLinks
    include ActiveModel::Model

    TAG_TYPES = %i[
      taxons
      ordered_related_items
      ordered_related_items_overrides
      mainstream_browse_pages
      parent
      organisations
    ].freeze

    attr_accessor :content_id, :previous_version, *TAG_TYPES

    # Find the links for a content item by its content ID
    def self.find(content_id)
      data = Services.publishing_api.get_expanded_links(content_id, generate: true).to_h

      links = data.fetch("expanded_links", {})

      tags = TAG_TYPES.index_with { |tag_type| links.fetch(tag_type.to_s, []) }

      new(
        content_id:,
        previous_version: data.fetch("version", 0),
        **tags,
      )
    end
  end
end
