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
      links_payload = generate_links_payload

      Services.statsd.time "patch_links" do
        Services.publishing_api.patch_links(
          content_item.content_id,
          links: links_payload,
          previous_version: params[:previous_version].to_i,
        )
      end

      if params[:notify]
        return false if params[:notification_message].blank?

        GdsApi.email_alert_api.create_content_change(
          Facets::FacetsTaggingNotificationPresenter.new(
            content_item,
            params[:notification_message],
            links_payload,
            email_alert_tags_payload,
          ).present,
        )
      end

      true
    end

  private

    attr_reader :facet_group_content_id

    def generate_links_payload
      facet_groups_content_ids = fetch_content_ids(:facet_groups)
      facet_values_content_ids = fetch_content_ids(:facet_values)
      ordered_related_items_ids = ordered_related_links

      if facet_values_content_ids.any?
        facet_groups_content_ids.push(facet_group_content_id)
      else
        facet_groups_content_ids.delete(facet_group_content_id)
      end

      {
        facet_groups: facet_groups_content_ids.uniq,
        facet_values: facet_values_content_ids,
        ordered_related_items: ordered_related_items_ids,
      }
    end

    def ordered_related_links
      Services.publishing_api.get_links(content_item.content_id)
        .to_hash
        .fetch("links")
        .fetch("ordered_related_items", [])
    end

    # FIXME: This is a temporary tag set which can be removed once
    # we've updated finder email signup to handle links based signup config
    # as we will no longer need to send tags as well as facet group links.
    def email_alert_tags_payload
      { "appear_in_find_eu_exit_guidance_business_finder" => "yes" }
    end

    def fetch_content_ids(tag_type)
      clean_input_array(params[tag_type])
    end

    def clean_input_array(select_form_input)
      Array(select_form_input).select(&:present?)
    end
  end
end
