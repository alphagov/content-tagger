namespace :eu_exit_business_finder do
  task retag_documents_to_facet_values: [:environment] do
    EuExitBusinessRakeMethods.replace_facet_values
    EuExitBusinessRakeMethods.retag_content_facet_values
    EuExitBusinessRakeMethods.delete_facet_values_from_content
  end
end

module EuExitBusinessRakeMethods
  def self.facet_values_to_replace
    # For each item in the array:
    # All documents tagged with `old_facet_value` will be re-tagged
    # with `new_facet_value`
    [
      {
        "old_facet_value": "9f3476e1-8ff0-455d-a14e-003236b2797c",
        "new_facet_value": "53f9ce4c-7cbb-447f-bdf1-a9b022896d3a",
      },

      {
        "old_facet_value": "b4e507df-f067-4749-9468-3de120775216",
        "new_facet_value": "24fd50fa-6619-46ca-96cd-8ce90fa076ce",
      },

      {
        "old_facet_value": "1e3e8abd-135d-4844-afa8-5c51df3d3c57",
        "new_facet_value": "34a6edd0-46ea-4a76-ae80-8c96709d4f59",
      },

      {
        "old_facet_value": "c1d8057c-76bf-431c-9ac8-6281a4b7b9ca",
        "new_facet_value": "34a6edd0-46ea-4a76-ae80-8c96709d4f59",
      },

      {
        "old_facet_value": "356f46a0-17d3-4ba4-8952-8c02244f9045",
        "new_facet_value": "18c3892e-8a0e-4884-906e-5938380eceee",
      },
    ]
  end

  def self.content_to_update_facet_values
    # For each base path:
    # The document will be untagged from `old_facet_value` and
    # will be re-tagged with `new_facet_value`
    [
      {
        "base_paths": [
          "/guidance/export-animal-bones-protein-and-other-by-products-special-rules",
          "/guidance/export-food-and-agricultural-products-special-rules",
          "/government/publications/farm-payments-if-theres-no-brexit-deal/farm-payments-if-theres-no-brexit-deal",
          "/guidance/how-to-comply-with-pesticide-regulations-after-brexit",
          "/government/publications/industrial-emissions-standards-best-available-techniques-if-theres-no-brexit-deal",
          "/guidance/protecting-food-and-drink-names-if-theres-no-brexit-deal",
          "/government/publications/receiving-rural-development-funding-if-theres-no-brexit-deal/receiving-rural-development-funding-if-theres-no-brexit-deal",
          "/guidance/the-farming-sector-and-preparing-for-eu-exit",
          "/government/publications/upholding-environmental-standards-if-theres-no-brexit-deal",
        ],
        "old_facet_value": "94b3cfe2-af89-4744-b8d7-7fc79edcbc85",
        "new_facet_value": "9d54c591-f5ca-4d0c-a484-12d5591987cb",
      },
      {
        "base_paths": [
          "/government/publications/approval-and-operation-of-plant-health-inspection-facilities-at-place-of-first-arrival",
          "/guidance/importing-and-exporting-plants-and-plant-products-if-theres-no-withdrawal-deal",
          "/guidance/trading-timber-imports-and-exports-if-theres-no-brexit-deal",
        ],
        "old_facet_value": "94b3cfe2-af89-4744-b8d7-7fc79edcbc85",
        "new_facet_value": "afd45eef-743a-417d-9245-3eab8322116d",
      },
    ]
  end

  def self.facet_values_to_untag
    # For each item in the array:
    # All content tagged to that facet value will be untagged
    %w[
      7536c0c4-fb41-43f4-a2c4-08f4fa9f5427
      5faa1741-fc55-4110-b342-de92f6324118
      14cf2a68-3297-44d3-ba01-a4426845b1b8
      040649fc-4e2c-4028-b846-77fe3eebd1f7
      94b3cfe2-af89-4744-b8d7-7fc79edcbc85
    ]
  end

  def self.replace_facet_values
    content_changes = []
    facet_values_to_replace.each do |facet_values_merge|
      content_ids = []
      content_links = Services.search_api.search_enum(
        filter_facet_values: facet_values_merge[:old_facet_value],
      ).pluck("link")
      content_links.each do |content_link|
        content_ids << Services.search_api.get_content(content_link).to_hash["raw_source"]["content_id"]
      end
      content_changes << {
        "content_ids": content_ids,
        "old_facet_value": facet_values_merge[:old_facet_value],
        "new_facet_value": facet_values_merge[:new_facet_value],
      }
    end

    bulk_retag_documents(content_changes)
  end

  def self.retag_content_facet_values
    content_changes = content_to_update_facet_values

    content_changes.each do |content_change|
      content_change[:content_ids] = Services.publishing_api.lookup_content_ids(base_paths: content_change[:base_paths]).values
    end

    bulk_retag_documents(content_changes)
  end

  def self.delete_facet_values_from_content
    facet_values_to_untag.each do |facet_value|
      content_ids = get_content_ids_from_facet_value(facet_value)
      content_ids.each do |content_id|
        links = Services.publishing_api.get_links(content_id).to_hash.fetch("links", {})
        content_facet_values = links.fetch("facet_values", [])
        content_facet_values.delete(facet_value)
        links["facet_values"] = content_facet_values
        Services.publishing_api.patch_links(content_id, links: links)
      end
    end
  end

  def self.get_content_ids_from_facet_value(facet_value)
    content_ids = []
    content_links = Services.search_api.search_enum(
      filter_facet_values: facet_value,
    ).pluck("link")
    content_links.each do |content_link|
      content_ids << Services.search_api.get_content(content_link).to_hash["raw_source"]["content_id"]
    end
    content_ids
  end

  def self.bulk_retag_documents(content_changes)
    content_changes.each do |content_change|
      content_change[:content_ids].each do |content_id|
        links = Services.publishing_api.get_links(content_id).to_hash.fetch("links", {})
        facet_values = links.fetch("facet_values", [])
        facet_values.delete(content_change[:old_facet_value])
        facet_values << content_change[:new_facet_value]
        links["facet_values"] = facet_values
        Services.publishing_api.patch_links(content_id, links: links)
      end
    end
  end
end
