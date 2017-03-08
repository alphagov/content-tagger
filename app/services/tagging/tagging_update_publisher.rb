# Receives the form input from the user and sends the links to the
# publishing-api.
module Tagging
  class TaggingUpdatePublisher
    attr_reader :content_item, :params
    attr_reader :errors

    def initialize(content_item, params)
      @content_item = content_item
      @params = params
      @errors = {}
    end

    def save_to_publishing_api
      return false unless valid?

      Services.statsd.time "patch_links" do
        Services.publishing_api.patch_links(
          content_item.content_id,
          links: generate_links_payload,
          previous_version: params[:previous_version].to_i,
        )
      end
    end

  private

    def valid?
      related_content_items.each do |related_item|
        next if related_item.content_id
        @errors[related_item.base_path] = "Not a known URL on GOV.UK"
      end

      @errors.none?
    end

    def generate_links_payload
      content_item.allowed_tag_types.reduce({}) do |payload, tag_type|
        content_ids = if tag_type == :ordered_related_items
                        related_content_items.map(&:content_id)
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

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end
  end
end
