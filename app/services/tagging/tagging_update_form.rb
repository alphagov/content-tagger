module Tagging
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model

    TAG_TYPES = ContentItemExpandedLinks::TAG_TYPES

    attr_accessor :content_item, :previous_version, :links, :related_item_errors, *TAG_TYPES

    delegate :content_id, :allowed_tag_types, to: :content_item

    def self.from_content_item(content_item)
      links = content_item.link_set

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }

        next unless tag_type.in? %i[ordered_related_items ordered_related_items_overrides]

        base_paths = links.send(tag_type).map { |links_hash| links_hash["base_path"] }

        # The number of extra empty form fields to add to a link section when the link
        # section shows an individual form input for each value. This allows users to
        # append new links to the end of the existing list.
        empty_entries = [""] * 5

        current_tags[tag_type] = base_paths + empty_entries
      end

      new(
        links:,
        content_item:,
        previous_version: links.previous_version,
        related_item_errors: {},
        **tag_values,
      )
    end

    def linkables
      @linkables ||= Linkables.new
    end

    def add_errors_for(related_item_type, errors_to_add)
      related_item_errors[related_item_type] = errors_to_add
    end

    def get_errors_for(related_item_type)
      related_item_errors.fetch(related_item_type, {})
    end

    def title_for_related_link(base_path)
      items = links.ordered_related_items + links.ordered_related_items_overrides
      link = items.find { |related_item| related_item.fetch("base_path") == base_path }

      if link.nil?
        # links is populated from the existing links. When we submit a form and
        # it fails, we may have additional related links we want to know the
        # titles of.
        # In practice this shouldn't actually be visible most of the time,
        # because with javascript enabled, the user can't enter invalid data,
        # and without it we don't display the titles. It is still possible to
        # see errors due to tagging conflicts though.
        # TODO: attempt to fetch missing links on demand.
        "Related item"
      else
        link.fetch("title")
      end
    end

    def update_attributes_from_form(params)
      @previous_version = params[:previous_version]

      TAG_TYPES.each do |tag_type|
        send("#{tag_type}=", params[tag_type])
      end
    end
  end
end
