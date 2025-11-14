# Receives the form input from the user and sends the links to the
# publishing-api.
module Tagging
  class TaggingUpdatePublisher
    attr_reader :content_item, :params, :related_item_errors, :related_item_overrides_errors

    def initialize(content_item, params)
      @content_item = content_item
      @params = params
      @related_item_errors = {}
      @related_item_overrides_errors = {}
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
      content_item.allowed_tag_types.reduce({}) do |payload, tag_type|
        content_ids = fetch_content_ids(tag_type)

        payload.merge(tag_type => content_ids)
      end
    end

  private

    def fetch_content_ids(tag_type)
      case tag_type
      when :ordered_related_items
        related_content_items.map(&:content_id)
      when :ordered_related_items_overrides
        related_content_items_overrides.map(&:content_id)
      else
        clean_input_array(params[tag_type])
      end
    end

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

    def related_content_items
      get_base_paths(:ordered_related_items)
    end

    def related_content_items_overrides
      get_base_paths(:ordered_related_items_overrides)
    end

    def get_base_paths(link_type)
      paths = clean_input_array(params[link_type]).map { |path| URI.parse(path).path }

      base_paths_content_items.select { |content_item| paths.include?(content_item.base_path) }
    end

    def base_paths_content_items
      @base_paths_content_items ||= begin
        fields = %i[ordered_related_items
                    ordered_related_items_overrides]
        base_paths = fields.flat_map { |f| clean_input_array(params[f]) }.uniq
        BasePathLookup.find_by_base_paths(base_paths)
      end
    end

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end
  end
end
