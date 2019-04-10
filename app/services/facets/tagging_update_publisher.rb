# Receives the form input from the user and sends the links to the
# publishing-api.
module Facets
  class TaggingUpdatePublisher
    attr_reader :content_item, :params

    def initialize(content_item, params, facet_group_content_id)
      @content_item = content_item
      @params = params
      @facet_group_content_id = facet_group_content_id
    end

    def save_to_publishing_api
      Services.statsd.time "patch_links" do
        Services.publishing_api.patch_links(
          content_item.content_id,
          links: generate_links_payload,
          previous_version: params[:previous_version].to_i,
        )
      end

      # Updates a finder content item so that it contains the
      # content_id of the current content item in the ordered_related_items
      # collection. This is how items get promoted or pinned in a finder.
      updated_items = updated_pinned_items
      unless updated_items == pinned_items
        # TODO: Currently only one finder is linked to a facet group
        # so there's only one item which can be pinned. In future we
        # will need to look up finders linked to groups.
        Services.statsd.time "patch_links" do
          Services.publishing_api.patch_links(
            FinderService::LINKED_FINDER_CONTENT_ID,
            links: { "ordered_related_items": updated_items }
          )
        end
      end

      if params[:notify]
        Services.publishing_api.notify(
          content_item.content_id,
          {
            publishing_app: "content-tagger",
            workflow_message: params[:notification_message]
          }
        )
      end

      true
    end

  private

    attr_reader :facet_group_content_id

    def updated_pinned_items
      updated_pinned_items = pinned_items.dup

      method = params[:promoted] ? :push : :delete
      updated_pinned_items.send(method, content_item.content_id)
      updated_pinned_items.sort.uniq
    end

    def generate_links_payload
      facet_groups_content_ids = fetch_content_ids(:facet_groups)
      facet_values_content_ids = fetch_content_ids(:facet_values)

      if facet_values_content_ids.any?
        facet_groups_content_ids.push(facet_group_content_id)
      else
        facet_groups_content_ids.delete(facet_group_content_id)
      end

      {
        facet_groups: facet_groups_content_ids.uniq,
        facet_values: facet_values_content_ids,
      }
    end

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
