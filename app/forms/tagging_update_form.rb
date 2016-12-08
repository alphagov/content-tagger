class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  attr_accessor(*ContentItemExpandedLinks::TAG_TYPES)

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.from_content_item_links(content_item_links)
    new(
      content_id: content_item_links.content_id,
      previous_version: content_item_links.previous_version,
      topics: extract_content_ids(content_item_links.topics),
      organisations: extract_content_ids(content_item_links.organisations),
      mainstream_browse_pages: extract_content_ids(content_item_links.mainstream_browse_pages),
      parent: extract_content_ids(content_item_links.parent),
      taxons: extract_content_ids(content_item_links.taxons),
      ordered_related_items: extract_content_ids(content_item_links.ordered_related_items)
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

    ContentItemExpandedLinks::TAG_TYPES.each do |tag_type|
      content_ids = send(tag_type)
      # Because the field might be a blacklisted field switched off in the form.
      next if content_ids.nil?
      payload.merge!(tag_type => clean_content_ids(content_ids))
    end

    payload
  end

private

  def self.extract_content_ids(links_hashes)
    unless links_hashes.nil?
      links_hashes.map {|links_hash| links_hash["content_id"]}
    end
  end

  def clean_content_ids(select_form_input)
    Array(select_form_input).select(&:present?)
  end
end
