# Receives the form input from the user and sends the links to the
# publishing-api.
module Facets
  class TaggingUpdatePublisher
    attr_reader :content_item, :params

    def initialize(content_item, params)
      @content_item = content_item
      @params = params
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

    def generate_links_payload
      TaggingUpdateForm::TAG_TYPES.reduce({}) do |payload, tag_type|
        content_ids = fetch_content_ids(tag_type)

        payload.merge(tag_type => content_ids)
      end
    end

  private

    def fetch_content_ids(tag_type)
      clean_input_array(params[tag_type])
    end

    def valid?
      true
    end

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end
  end
end
