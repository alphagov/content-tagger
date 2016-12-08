class ContentItemExpandedLinks
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  TAG_TYPES = %i(topics mainstream_browse_pages organisations taxons parent ordered_related_items).freeze
  attr_accessor(*TAG_TYPES)

  # Find the links for a content item by its content ID
  def self.find(content_id)
    data = Services.publishing_api.get_expanded_links(content_id)

    links = data['links'] || {}

    new(
      content_id: content_id,
      previous_version: data['version'] || 0,
      topics: links['topics'],
      organisations: links['organisations'],
      mainstream_browse_pages: links['mainstream_browse_pages'],
      parent: links['parent'],
      taxons: links['taxons'],
      ordered_related_items: links['ordered_related_items']
    )
  end
end
