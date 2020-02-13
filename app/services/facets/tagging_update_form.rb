module Facets
  # ActiveModel-compliant object that is passed into the tagging form.
  class TaggingUpdateForm
    include ActiveModel::Model
    attr_accessor :content_item, :previous_version,
                  :notify, :notification_message, :links

    delegate :content_id, to: :content_item

    TAG_TYPES = %i[facet_values].freeze
    attr_accessor(*TAG_TYPES)

    def self.from_content_item(content_item)
      links = content_item.facets_link_set

      tag_values = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.send(tag_type).map { |links_hash| links_hash["content_id"] }
      end

      new(
        links: links,
        content_item: content_item,
        previous_version: links.previous_version,
        **tag_values,
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
      @notify = params[:notify]
      @notification_message = params[:notification_message]
      validate_notification

      TAG_TYPES.each do |tag_type|
        send("#{tag_type}=", params[tag_type])
      end
    end

    def validate_notification
      return unless notify && notification_message.blank?

      errors.add(
        :notification_message,
        "must be present when notifying subscribers",
      )
    end

    def facet_values
      links.facet_values.map { |fv| fv["content_id"] }
    end
  end
end
