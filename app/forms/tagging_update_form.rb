class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  attr_accessor(*ContentItemLinks::TAG_TYPES)

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.from_content_item_links(content_item_links)
    new(
      content_id: content_item_links.content_id,
      previous_version: content_item_links.previous_version,
      topics: content_item_links.topics,
      organisations: content_item_links.organisations,
      mainstream_browse_pages: content_item_links.mainstream_browse_pages,
      parent: content_item_links.parent,
      taxons: content_item_links.taxons,
      ordered_related_items: content_item_links.ordered_related_items
    )
  end

  def to_content_items_links
    ContentItemLinks.new(
      content_id: content_id,
      previous_version: previous_version,
      topics: topics,
      organisations: organisations,
      mainstream_browse_pages: mainstream_browse_pages,
      parent: parent,
      taxons: taxons
    )
  end
end
