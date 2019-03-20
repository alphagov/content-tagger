module Facets
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model
    attr_accessor :content_item, :previous_version, :links

    delegate :content_id, to: :content_item

    TAG_TYPES = %i[facet_groups facet_values].freeze
    attr_accessor(*TAG_TYPES)

    def self.from_content_item(content_item)
      links = content_item.facets_link_set

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }

        base_paths = links.send(tag_type).map { |links_hash| links_hash["base_path"] }

        # The number of extra empty form fields to add to a link section when the link
        # section shows an individual form input for each value. This allows users to
        # append new links to the end of the existing list.
        empty_entries = [""] * 5
        current_tags[tag_type] = base_paths + empty_entries
      end

      new(
        links: links,
        content_item: content_item,
        previous_version: links.previous_version,
        **tag_values
      )
    end

    def allowed_tag_types
      TAG_TYPES
    end

    def linkables
      @linkables ||= Linkables.new
    end

    def update_attributes_from_form(params)
      @previous_version = params[:previous_version]

      TAG_TYPES.each do |tag_type|
        send("#{tag_type}=", params[tag_type])
      end
    end

    def facet_group_name
      links.facet_groups.first["title"]
    end

    def facet_groups
      links.facet_groups.map { |fv| fv["content_id"] }
    end

    def facet_values
      links.facet_values.map { |fv| fv["content_id"] }
    end
  end
end
