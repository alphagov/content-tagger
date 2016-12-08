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
      ordered_related_items: extract_base_paths(content_item_links.ordered_related_items)
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

    tag_types_with_content_id_values = ContentItemExpandedLinks::TAG_TYPES - [:ordered_related_items]

    tag_types_with_content_id_values.each do |tag_type|
      content_ids = send(tag_type)
      # Because the field might be a blacklisted field switched off in the form.
      next if content_ids.nil?
      payload.merge!(tag_type => clean_input_array(content_ids))
    end

    unless ordered_related_items.nil?
      payload[:ordered_related_items] = clean_input_array(ordered_related_items).map {|ri| find_by_base_path(ri)}
    end

    payload
  end

private

  def find_by_base_path(base_path)
    content_lookup = ContentLookupForm.new(base_path: base_path)
    if content_lookup.valid?
      content_lookup.content_id
    else
      base_path # FIXME
    end
  end

  def self.extract_content_ids(links_hashes)
    unless links_hashes.nil?
      links_hashes.map {|links_hash| links_hash["content_id"]}
    end
  end

  def self.extract_base_paths(links_hashes)
    unless links_hashes.nil?
      links_hashes.map {|links_hash| links_hash["base_path"]}
    end
  end

  def clean_input_array(select_form_input)
    Array(select_form_input).select(&:present?)
  end
end
