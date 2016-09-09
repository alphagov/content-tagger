module PublishingApiHelper
  def publishing_api_has_taxons(taxons)
    publishing_api_has_content(
      taxons,
      document_type: "taxon",
      order: '-public_updated_at',
    )
  end

  def publishing_api_has_taxon_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_taxons, base_paths),
      document_type: 'taxon'
    )
  end

  def publishing_api_has_topic_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_topics, base_paths),
      document_type: 'topic'
    )
  end

  def publishing_api_has_organisation_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_organisations, base_paths),
      document_type: 'organisation'
    )
  end

  def publishing_api_has_mainstream_browse_page_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_mainstream_browse_pages, base_paths),
      document_type: 'mainstream_browse_page'
    )
  end

  def select_by_base_path(tags, base_paths)
    tags.select { |tag| base_paths.include?(tag["base_path"]) }
  end

  def stubbed_taxons
    [
      {
        "public_updated_at" => "2016-04-06 16:25:37.238",
        "title" => "Vehicle plating",
        "content_id" => "17f91fdf-a36f-48f0-989c-a056d56876ee",
        "publication_state" => "live",
        "base_path" => "/alpha-taxonomy/vehicle-plating",
        "internal_name" => "Vehicle plating"
      },
    ]
  end

  def stubbed_topics
    [
      {
        "public_updated_at" => "2016-04-06 16:25:37.238",
        "title" => "ID OF ALREADY TAGGED",
        "content_id" => "ID-OF-ALREADY-TAGGED",
        "publication_state" => "live",
        "base_path" => "/topic/id-of-already-tagged",
        "internal_name" => "Test / Id of already tagged"
      },
      {
        "public_updated_at" => "2016-04-07 10:34:05",
        "title" => "Pension scheme administration",
        "content_id" => "e1d6b771-a692-4812-a4e7-7562214286ef",
        "publication_state" => "live",
        "base_path" => "/topic/business-tax/pension-scheme-administration",
        "internal_name" => "Business tax / Pension scheme administration"
      },
    ]
  end

  def stubbed_organisations
    [
      {
        "public_updated_at" => "2014-10-15 14:35:22",
        "title" => "Student Loans Company",
        "content_id" => "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
        "publication_state" => "live",
        "base_path" => "/government/organisations/student-loans-company",
        "internal_name" => "Student Loans Company"
      },
    ]
  end

  def stubbed_mainstream_browse_pages
    [
      {
        "public_updated_at" => "2016-03-27 10:32:40",
        "title" => "Vehicle tax and SORN",
        "content_id" => "d93d0cff-a035-4c49-8bc2-eaf6e040c42d",
        "publication_state" => "live",
        "base_path" => "/browse/driving/car-tax-discs",
        "internal_name" => "Driving and transport / Vehicle tax and SORN"
      },
    ]
  end
end
