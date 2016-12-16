class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  TAG_TYPES = ContentItemExpandedLinks::TAG_TYPES
  attr_accessor(*TAG_TYPES)

  # The number of extra empty form fields to add to a link section when the link
  # section shows an individual form input for each value. This allows users to
  # append new links to the end of the existing list.
  EXTRA_TEXT_FIELD_COUNT = 5

  if TAG_TYPES.include?(:ordered_related_items)
    validate :related_item_paths_should_be_valid
  end

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.from_content_item_links(content_item_links)
    tags = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
      if tag_type == :ordered_related_items
        base_paths = extract_base_paths(
          content_item_links.ordered_related_items
        )
        current_tags[tag_type] = pad_with_empty_items(base_paths)
      else
        current_tags[tag_type] = extract_content_ids(
          content_item_links.send(tag_type)
        )
      end
    end

    new(
      content_id: content_item_links.content_id,
      previous_version: content_item_links.previous_version,
      **tags
    )
  end

  def links_payload(tag_types)
    tag_types.each_with_object({}) do |tag_type, payload|
      field_value = send(tag_type)

      payload[tag_type] =
        if tag_type == :ordered_related_items
          related_content_items.map(&:content_id)
        else
          clean_input_array(field_value)
        end
    end
  end

  def related_content_items
    @related_content_items ||= BasePathLookup.find_by_base_paths(
      clean_input_array(ordered_related_items)
    )
  end

  def self.extract_content_ids(links_hashes)
    links_hashes.map { |links_hash| links_hash["content_id"] }
  end

  def self.extract_base_paths(links_hashes)
    unless links_hashes.nil?
      links_hashes.map { |links_hash| links_hash["base_path"] }
    end
  end

  def self.pad_with_empty_items(items)
    (items || []) + [""] * EXTRA_TEXT_FIELD_COUNT
  end

  private_class_method(:extract_content_ids, :extract_base_paths, :pad_with_empty_items)

private

  def clean_input_array(select_form_input)
    Array(select_form_input).select(&:present?)
  end

  def related_item_paths_should_be_valid
    unless ordered_related_items.nil?
      related_content_items.each do |ri|
        if ri.content_id.nil?
          index = ordered_related_items.index(ri.base_path)
          errors[:"ordered_related_items[#{index}]"] << "Could not find content item with this URL or path"
        end
      end
    end
  end
end
