module Tagging
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model
    attr_accessor :content_item, :previous_version, :related_item_errors

    delegate :content_id, :allowed_tag_types, to: :content_item

    TAG_TYPES = ContentItemExpandedLinks::TAG_TYPES
    attr_accessor(*TAG_TYPES)

    def self.from_content_item(content_item)
      links = content_item.link_set

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }

        next unless tag_type == :ordered_related_items
        base_paths = links.ordered_related_items.map { |links_hash| links_hash["base_path"] }

        # The number of extra empty form fields to add to a link section when the link
        # section shows an individual form input for each value. This allows users to
        # append new links to the end of the existing list.
        empty_entries = [""] * 5
        current_tags[tag_type] = base_paths + empty_entries
      end

      new(
        content_item: content_item,
        previous_version: links.previous_version,
        **tag_values
      )
    end

    def linkables
      @linkables ||= Linkables.new
    end

    def related_item_errors
      @related_item_errors ||= {}
    end

    def update_attributes_from_form(params)
      @previous_version = params[:previous_version]

      TAG_TYPES.each do |tag_type|
        send("#{tag_type}=", params[tag_type])
      end
    end
  end
end
