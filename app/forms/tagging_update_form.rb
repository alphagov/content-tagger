class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_item, :content_id, :previous_version

  TAG_TYPES = %i(topics mainstream_browse_pages organisations taxons parent)
  attr_accessor(*TAG_TYPES)

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.init_with_content_item(content_item)
    link_set = content_item.link_set

    new(
      content_item: content_item,
      previous_version: link_set.version,
      topics: link_set.links['topics'],
      organisations: link_set.links['organisations'],
      mainstream_browse_pages: link_set.links['mainstream_browse_pages'],
      parent: link_set.links['parent'],
      taxons: link_set.links['taxons'],
    )
  end

  def content_id
    @content_id ||= content_item.content_id
  end

  def publish!
    Services.publishing_api.patch_links(
      content_id,
      links: links_payload,
      previous_version: previous_version.to_i,
    )
  end

  def links_payload
    payload = {}

    TAG_TYPES.each do |tag_type|
      content_ids = send(tag_type)
      # Because the field might be a blacklisted field switched off in the form.
      next if content_ids.nil?
      payload.merge!(tag_type => clean_content_ids(content_ids))
    end

    payload
  end

private

  def clean_content_ids(select_form_input)
    Array(select_form_input).select(&:present?)
  end
end
