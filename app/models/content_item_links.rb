class ContentItemLinks
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  TAG_TYPES = %i(topics mainstream_browse_pages organisations taxons parent ordered_related_items).freeze
  attr_accessor(*TAG_TYPES)

  # Find the links for a content item by its content ID
  def self.find(content_id)
    data = Services.publishing_api.get_links(content_id)

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
