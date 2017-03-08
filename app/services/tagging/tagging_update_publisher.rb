# Receives the form input from the user and sends the links to the
# publishing-api.
module Tagging
  class TaggingUpdatePublisher
    attr_reader :content_item, :params
    attr_reader :related_item_errors, :related_item_overrides_errors

    def initialize(content_item, params)
      @content_item = content_item
      @params = params
      @related_item_errors = {}
      @related_item_overrides_errors = {}
    end

    def save_to_publishing_api
      return false unless valid?

      Services.publishing_api.patch_links(
        content_item.content_id,
        links: generate_links_payload,
        previous_version: params[:previous_version].to_i,
      )
    end

  private

    def valid?
      related_content_items.each do |related_item|
        next if related_item.content_id
        @related_item_errors[related_item.base_path] = "Not a known URL on GOV.UK"
      end

      related_content_items_overrides.each do |related_item|
        next if related_item.content_id
        @related_item_overrides_errors[related_item.base_path] = "Not a known URL on GOV.UK"
      end

      @related_item_errors.none? && @related_item_overrides_errors.none?
    end

    def generate_links_payload
      content_item.allowed_tag_types.reduce({}) do |payload, tag_type|
        content_ids = if tag_type == :ordered_related_items
                        related_content_items.map(&:content_id)
                      elsif tag_type == :ordered_related_items_overrides
                        related_content_items_overrides.map(&:content_id)
                      else
                        clean_input_array(params[tag_type])
                      end

        payload.merge(tag_type => content_ids)
      end
    end

    def related_content_items
      @related_content_items ||= BasePathLookup.find_by_base_paths(
        clean_input_array(params[:ordered_related_items])
      )
    end

    def related_content_items_overrides
      @related_content_items_overrides ||= BasePathLookup.find_by_base_paths(
        clean_input_array(params[:ordered_related_items_overrides])
      )
    end

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end
  end
end
