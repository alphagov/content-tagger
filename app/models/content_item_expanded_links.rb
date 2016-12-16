class ContentItemExpandedLinks
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  TAG_TYPES = %i(taxons mainstream_browse_pages parent topics organisations).freeze
  attr_accessor(*TAG_TYPES)

  # Find the links for a content item by its content ID
  def self.find(content_id)
    data = Services.publishing_api.get_expanded_links(content_id).to_h

    links = data.fetch('expanded_links', {})

    new(
      content_id: content_id,
      previous_version: data.fetch('version', 0),
      topics: links.fetch('topics', []),
      organisations: links.fetch('organisations', []),
      mainstream_browse_pages: links.fetch('mainstream_browse_pages', []),
      parent: links.fetch('parent', []),
      taxons: links.fetch('taxons', []),
    )
  end
end
