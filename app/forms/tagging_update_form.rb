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
    )
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

    ContentItemLinks::TAG_TYPES.each do |tag_type|
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
