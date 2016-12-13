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
      taxons: extract_content_ids(content_item_links.taxons)
    )
  end

  def links_payload(tag_types)
    tag_types.each_with_object({}) do |tag_type, payload|
      content_ids = send(tag_type)
      payload[tag_type] = clean_content_ids(content_ids)
    end
  end

  def self.extract_content_ids(links_hashes)
    links_hashes.map { |links_hash| links_hash["content_id"] }
  end

private

  private_class_method :extract_content_ids

  def clean_content_ids(select_form_input)
    Array(select_form_input).select(&:present?)
  end
end
