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
      Services.statsd.time "patch_links" do
        Services.publishing_api.patch_links(
          content_item.content_id,
          links: generate_links_payload,
          previous_version: params[:previous_version].to_i,
        )
      end

      promote_finder_item
    end

    # Updates a finder content item so that it contains the
    # content_id of the current content item in the ordered_related_items
    # collection. This is how items get promoted or pinned in a finder.
    def promote_finder_item
      content_id = content_item.content_id
      updated_pinned_items = pinned_items.dup

      method = params[:promoted] ? :push : :delete
      updated_pinned_items.send(method, content_id)
      updated_pinned_items = updated_pinned_items.sort.uniq

      return if updated_pinned_items == pinned_items

      # TODO: Currently only one finder is linked to a facet group
      # so there's only one item which can be pinned. In future we
      # will need to look up finders linked to groups.
      Services.statsd.time "patch_links" do
        Services.publishing_api.patch_links(
          FinderService::LINKED_FINDER_CONTENT_ID,
          links: { "ordered_related_items": updated_pinned_items }
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

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end

    def pinned_items
      @pinned_items ||= FinderService.new.pinned_item_links.sort.uniq
    end
  end
end
