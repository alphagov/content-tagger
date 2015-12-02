class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_item, :content_id, :previous_version
  attr_reader :topics, :organisations, :mainstream_browse_pages, :parent

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.init_with_content_item(content_item)
    link_set = Services.publishing_api.get_links(content_item.content_id)

    new(
      content_item: content_item,
      previous_version: link_set.version,
      topics: link_set.links['topics'],
      organisations: link_set.links['organisations'],
      mainstream_browse_pages: link_set.links['mainstream_browse_pages'],
      parent: link_set.links['parent'],
    )
  end

  def content_id
    @content_id ||= content_item.content_id
  end

  def publish!
    Services.publishing_api.put_links(
      content_id,
      links: {
        topics: topics,
        mainstream_browse_pages: mainstream_browse_pages,
        organisations: organisations,
        parent: parent,
      },
      previous_version: previous_version.to_i,
    )
  end

  def allowed_tag_types
    AllowedTagsFor.allowed_tag_types(content_item)
  end

  def topics=(topic_ids)
    @topics = Array(topic_ids).select(&:present?)
  end

  def organisations=(organisation_ids)
    @organisations = Array(organisation_ids).select(&:present?)
  end

  def mainstream_browse_pages=(mainstream_browse_page_ids)
    @mainstream_browse_pages = Array(mainstream_browse_page_ids).select(&:present?)
  end

  def parent=(parent_id)
    @parent = Array(parent_id).select(&:present?)
  end
end
