module Tagging
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model
    attr_accessor :content_item, :previous_version, :links
    attr_writer :related_item_errors, :related_item_overrides_errors

    delegate :content_id, :allowed_tag_types, to: :content_item

    TAG_TYPES = ContentItemExpandedLinks::TAG_TYPES
    attr_accessor(*TAG_TYPES)

    def self.from_content_item(content_item)
      links = content_item.link_set

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }

        next unless tag_type.in? %i[ordered_related_items ordered_related_items_overrides]
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["base_path"] }
      end

      new(
        links: links,
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

    def related_item_overrides_errors
      @related_item_overrides_errors ||= {}
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
