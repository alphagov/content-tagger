namespace :travel_advice do
  desc "Adds step-by-step to related links"
  task add_step_by_step: :environment do
    link_to_add = "8c0c7b83-5e0b-4bed-9121-1c394e2f96f3"
    position = 1

    response = Services.publishing_api.get_editions(
      per_page: 300,
      publishing_app: "travel-advice-publisher",
      document_types: %w[travel_advice],
      states: %w[published],
    )

    response["results"].each do |edition|
      links = Services.publishing_api.get_links(edition["content_id"])["links"]
      next unless links && links["ordered_related_items"]

      links["ordered_related_items"].insert(position, link_to_add)

      Services.publishing_api.patch_links(
        edition["content_id"],
        links: links,
        bulk_publishing: true,
      )
    end
  end
end
