namespace :travel_advice do
  desc ""
  task crisis_support: :environment do
    take_out = "5dc09a0e-7631-11e4-a3cb-005056011aef" # /guidance/how-to-deal-with-a-crisis-overseas
    swap_in = "aad65646-964d-4f68-ac22-5bc6c8281336" # /government/collections/support-for-british-nationals-abroad

    response = Services.publishing_api.get_editions(
      per_page: 300,
      publishing_app: "travel-advice-publisher",
      document_types: %w[travel_advice],
      states: %w[published],
    )

    response["results"].each do |edition|
      links = Services.publishing_api.get_links(edition["content_id"])["links"]
      next unless links && links["ordered_related_items"]

      p "Updating links for item #{edition['content_id']}"

      begin
        index_of_link = links["ordered_related_items"].index(take_out)

        links["ordered_related_items"][index_of_link] = swap_in if index_of_link

        Services.publishing_api.patch_links(
          edition["content_id"],
          links: links,
          bulk_publishing: true,
        )
      rescue GdsApi::TimedOutException => e
        p "Problem attempting to update for content item #{edition['content_id']}"
        pp e
        next
      end
    end
  end
end
