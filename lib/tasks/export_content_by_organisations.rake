namespace :govuk do
  # bundle exec rake govuk:export_content_by_organisations[uk-border-agency,border-force]
  desc "Export content by organisations as CSV"
  task export_content_by_organisations: [:environment] do |_, args|
    website_root = Plek.new.website_root

    fields = %w[
      link
      title
      description
      content_store_document_type
      primary_publishing_organisation
      organisations
      public_timestamp
    ]

    args.extras.each do |organisation_slug|
      puts organisation_slug

      content_items_enum = Services.search_api.search_enum(
        {
          fields: fields.join(","),
          filter_primary_publishing_organisation: organisation_slug,
        },
      )

      print "- saving items to CSV"

      filename = "#{organisation_slug}.csv"
      CSV.open(filename, "wb", headers: fields, write_headers: true) do |csv|
        content_items_enum.each do |content_item|
          content_item["link"] = begin
            # Add gov.uk to the base path
            "#{website_root}#{content_item['link']}"
          end

          content_item["primary_publishing_organisation"] = begin
            # There should only be one primary publishing organisation
            content_item["primary_publishing_organisation"].first
          end

          content_item["organisations"] = begin
            # Only keep the slug for organisations
            content_item["organisations"].map { |org| org["slug"] }.join(",")
          end

          csv << content_item.slice(*fields)
          print "."
        end
      end

      puts "\n- saved to #{File.expand_path(filename)}"
    end
  end
end
