namespace :govuk do
  # bundle exec rake govuk:export_content_by_organisations[uk-border-agency,border-force]
  desc "Export taxons of mainstream content as CSV"
  task export_mainstream_taxons: [:environment] do
    content_types = %w[
      answer
      guide
      simple_smart_answer
      transaction
      completed_transaction
      travel_advice_index
      local_transaction
      travel_advice
      licence
    ]

    fields = %w[
      link
      title
    ]

    content_items_enum = Services.rummager.search_enum(
      fields: fields,
      filter_content_store_document_type: content_types
    )

    print "- saving items to CSV"

    filename = 'tmp/mainstream.csv'
    CSV.open(filename, "wb", headers: ['mainstream title', 'mainstream path', 'taxon title', 'taxon link', 'taxon title', 'taxon link', 'taxon title', 'taxon link'], write_headers: true) do |csv|
      content_items_enum.each do |content_item|
        link = content_item["link"]
        title = content_item["title"]

        content_item = Services.live_content_store.content_item(link)
        taxons = content_item.dig('links', 'taxons') || []

        row = [title, link]
        taxons.each do |taxon|
          row << taxon['title'] << taxon['base_path']
        end
        csv << row
        puts row
      end
    end
  end
end
