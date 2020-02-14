require_relative("email_alert_api_helper")

module PublishingApiHelper
  include EmailAlertApiHelper

  def stub_empty_bulk_taxons_lookup
    url = Plek.current.find("publishing-api") + "/v2/links/by-content-id"
    stub_request(:post, url).to_return(body: {}.to_json)
  end

  def stub_bulk_taxons_lookup(content_ids, taxons)
    url = Plek.current.find("publishing-api") + "/v2/links/by-content-id"
    body = { content_ids: array_including(content_ids) }
    response_hash = content_ids.each_with_object({}) do |content_id, obj|
      obj[content_id] = { "links" => { "taxons" => taxons } }
    end
    stub_request(:post, url).with(body: body).to_return(body: response_hash.to_json)
  end

  def stub_requests_for_show_page(taxon)
    content_id = taxon.fetch("content_id")

    publishing_api_has_item(taxon)
    publishing_api_has_links(content_id: content_id, links: {})
    publishing_api_has_expanded_links(content_id: content_id, expanded_links: {})
    publishing_api_has_linked_items([], content_id: content_id, link_type: "taxons")
    stub_email_requests_for_show_page
  end

  def publishing_api_has_content_items(items, options = {})
    default_options = {
      document_type: BulkTagging::Search.default_document_types,
      page: 1,
      q: "",
      fields: %i[content_id document_type title base_path],
      search_in: %i[title base_path details.internal_name],
    }

    publishing_api_has_content(
      items,
      default_options.merge(options),
    )
  end

  def publishing_api_has_taxons(taxons, options = {})
    default_options = {
      document_type: "taxon",
      order: "-public_updated_at",
      page: 1,
      per_page: 50,
      q: "",
      search_in: %i[title base_path details.internal_name],
      states: %w[published],
    }

    publishing_api_has_content(taxons, default_options.merge(options))
  end

  def publishing_api_has_draft_taxons(taxons, options = {})
    default_options = {
      document_type: "taxon",
      order: "-public_updated_at",
      page: 1,
      per_page: 50,
      q: "",
      states: %w[draft],
    }

    publishing_api_has_content(taxons, default_options.merge(options))
  end

  def publishing_api_has_deleted_taxons(taxons, options = {})
    default_options = {
      document_type: "taxon",
      order: "-public_updated_at",
      page: 1,
      per_page: 50,
      q: "",
      search_in: %i[title base_path details.internal_name],
      states: %w[unpublished],
    }

    publishing_api_has_content(taxons, default_options.merge(options))
  end

  def publishing_api_has_taxon_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_taxons, base_paths),
      document_type: "taxon",
    )
  end

  def publishing_api_has_topic_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_topics, base_paths),
      document_type: "topic",
    )
  end

  def publishing_api_has_organisation_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_organisations, base_paths),
      document_type: "organisation",
    )
  end

  def publishing_api_has_need_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_needs, base_paths),
      document_type: "need",
    )
  end

  def publishing_api_has_mainstream_browse_page_linkables(base_paths)
    publishing_api_has_linkables(
      select_by_base_path(stubbed_mainstream_browse_pages, base_paths),
      document_type: "mainstream_browse_page",
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
        "publication_state" => "published",
        "base_path" => "/alpha-taxonomy/vehicle-plating",
        "internal_name" => "Vehicle plating",
      },
      {
        "public_updated_at" => "2017-02-07 14:22:48",
        "title" => "Vehicle weights explained",
        "content_id" => "4b5e77f7-69e5-45a9-9061-348cdce876fb",
        "publication_state" => "draft",
        "base_path" => "/alpha-taxonomy/vehicle-weights-explained",
        "internal_name" => "Vehicle weights explained",
      },
    ]
  end

  def stubbed_topics
    [
      {
        "public_updated_at" => "2016-04-06 16:25:37.238",
        "title" => "ID OF ALREADY TAGGED",
        "content_id" => "ID-OF-ALREADY-TAGGED",
        "publication_state" => "published",
        "base_path" => "/topic/id-of-already-tagged",
        "internal_name" => "Test / Id of already tagged",
      },
      {
        "public_updated_at" => "2016-04-07 10:34:05",
        "title" => "Pension scheme administration",
        "content_id" => "e1d6b771-a692-4812-a4e7-7562214286ef",
        "publication_state" => "published",
        "base_path" => "/topic/business-tax/pension-scheme-administration",
        "internal_name" => "Business tax / Pension scheme administration",
      },
    ]
  end

  def stubbed_organisations
    [
      {
        "public_updated_at" => "2014-10-15 14:35:22",
        "title" => "Student Loans Company",
        "content_id" => "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
        "publication_state" => "published",
        "base_path" => "/government/organisations/student-loans-company",
        "internal_name" => "Student Loans Company",
      },
    ]
  end

  def stubbed_needs
    [
      {
        "title" => "As a user, I need to apply for a copy of a marriage certificate, so that I can prove identity and have a record of the marriage, or research my family history (100569)",
        "content_id" => "29e9fb40-69af-4c4c-bd56-02e3c825a63b",
        "publication_state" => "published",
        "base_path" => "/needs/apply-for-a-copy-of-a-marriage-certificate",
        "internal_name" => "As a user, I need to apply for a copy of a marriage certificate, so that I can prove identity and have a record of the marriage, or research my family history (100569)",
      },
    ]
  end

  def stubbed_mainstream_browse_pages
    [
      {
        "public_updated_at" => "2016-03-27 10:32:40",
        "title" => "Vehicle tax and SORN",
        "content_id" => "d93d0cff-a035-4c49-8bc2-eaf6e040c42d",
        "publication_state" => "published",
        "base_path" => "/browse/driving/car-tax-discs",
        "internal_name" => "Driving and transport / Vehicle tax and SORN",
      },
    ]
  end
end
