module Facets
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model
    attr_accessor :content_item, :previous_version, :promoted, :links

    delegate :content_id, to: :content_item

    TAG_TYPES = %i[facet_groups facet_values].freeze
    attr_accessor(*TAG_TYPES)

    def self.from_content_item(content_item)
      links = content_item.facets_link_set
      finder_links = Facets::FinderService.new.pinned_item_links
      promoted = finder_links.include?(content_item.content_id)

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }
      end

      new(
        links: links,
        content_item: content_item,
        previous_version: links.previous_version,
        promoted: promoted,
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
      @promoted = params[:promoted]

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
