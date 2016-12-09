class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  attr_accessor(*ContentItemExpandedLinks::TAG_TYPES)

  # The number of extra empty form fields to add to a link section when the link
  # section shows an individual form input for each value. This allows users to
  # append new links to the end of the existing list.
  # ExtraFormItemCount = 5

  RelatedContentItem = Struct.new("RelatedContentItem", :content_id, :base_path)

  validate :related_item_paths_should_be_valid

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
      ordered_related_items: pad_with_empty_items(extract_base_paths(content_item_links.ordered_related_items))
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
      payload[:ordered_related_items] =
        self.class.find_by_base_paths(clean_input_array(ordered_related_items)).map(&:content_id)
    end

    payload
  end

  def self.find_by_base_paths(related_items)
    if related_items.empty?
      []
    else
      base_paths = related_items.map { |ri| URI.parse(ri).path }
      content_id_by_path = Services.publishing_api.lookup_content_ids(base_paths: base_paths)

      base_paths.map { |path| RelatedContentItem.new(content_id_by_path[path], path) }
    end
  end

  def self.extract_content_ids(links_hashes)
    unless links_hashes.nil?
      links_hashes.map { |links_hash| links_hash["content_id"] }
    end
  end

  def self.extract_base_paths(links_hashes)
    unless links_hashes.nil?
      links_hashes.map { |links_hash| links_hash["base_path"] }
    end
  end

  def self.pad_with_empty_items(items)
    (items || []) + [""] * 5
  end

  private_class_method(:extract_content_ids, :extract_base_paths)

private

  def clean_input_array(select_form_input)
    Array(select_form_input).select(&:present?)
  end

  def related_item_paths_should_be_valid
    unless ordered_related_items.nil?
      base_paths = clean_input_array(ordered_related_items).map { |ri| URI.parse(ri).path }

      related_items = self.class.find_by_base_paths(base_paths)

      related_items.each do |ri|
        if ri.content_id.nil?
          index = ordered_related_items.index(ri.base_path)
          errors[:"ordered_related_items[#{index}]"] << "Could not find content item with this URL or path"
        end
      end
    end
  end
end
