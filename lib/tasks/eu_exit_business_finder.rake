namespace :eu_exit_business_finder do
  desc <<-DESC
    Adds a link to the EU Exit Business Readiness Finder to all content items which are tagged to this finder
  DESC
  task add_related_link_to_tagged_content: [:environment] do
    facet_group_content_id = "52435175-82ed-4a04-adef-74c0199d0f46"
    finder_content_id = "42ce66de-04f3-4192-bf31-8394538e0734"

    content_ids = Services.publishing_api.get_linked_items(
      facet_group_content_id, link_type: "facet_groups", fields: %w[content_id]
    ).pluck('content_id')

    content_ids.each do |content_id|
      ordered_links = Services.publishing_api.get_links(content_id)
        .to_hash
        .fetch("links")
        .fetch("ordered_related_items", [])
      Services.publishing_api.patch_links(content_id, links: { ordered_related_items: ordered_links.unshift(finder_content_id) })
    end
  end
end
