module PublishingApiHelper
  include ContentItemHelper

  def publishing_api_has_content_items_for_linkables(items, options = {})
    default_options = {
      q: '',
      page: 1,
      per_page: 10_000,
      states: %w(live published draft),
      fields: [:content_id, :publication_state, :title, :base_path, :details]
    }

    publishing_api_has_content(
      items,
      default_options.merge(options)
    )
  end

  def publishing_api_has_content_items(items, options = {})
    default_options = {
      document_type: BulkTagging::Search.default_document_types,
      page: 1,
      q: '',
      fields: [:content_id, :document_type, :title, :base_path]
    }

    publishing_api_has_content(
      items,
      default_options.merge(options)
    )
  end

  def publishing_api_has_taxons(taxons, options = {})
    default_options = {
      document_type: "taxon",
      order: '-public_updated_at',
      page: 1,
      per_page: 50,
      q: '',
      states: ["published"],
    }

    publishing_api_has_content(taxons, default_options.merge(options))
  end

  def publishing_api_has_taxon_linkables(base_paths)
    publishing_api_has_content_items_for_linkables(
      select_by_base_path(stubbed_taxons, base_paths),
      document_type: 'taxon'
    )
  end

  def publishing_api_has_topic_linkables(base_paths)
    publishing_api_has_content_items_for_linkables(
      select_by_base_path(stubbed_topics, base_paths),
      document_type: 'topic'
    )
  end

  def publishing_api_has_organisation_linkables(base_paths)
    publishing_api_has_content_items_for_linkables(
      select_by_base_path(stubbed_organisations, base_paths),
      document_type: 'organisation'
    )
  end

  def publishing_api_has_need_linkables(base_paths)
    publishing_api_has_content_items_for_linkables(
      select_by_base_path(stubbed_needs, base_paths),
      document_type: 'need'
    )
  end

  def publishing_api_has_mainstream_browse_page_linkables(base_paths)
    publishing_api_has_content_items_for_linkables(
      select_by_base_path(stubbed_mainstream_browse_pages, base_paths),
      document_type: 'mainstream_browse_page'
    )
  end

  def select_by_base_path(tags, base_paths)
    tags.select { |tag| base_paths.include?(tag["base_path"]) }
  end

  def stubbed_taxons
    [
      basic_content_item(
        "Vehicle plating",
        other_fields: {
          document_type: 'taxon',
          content_id: "17f91fdf-a36f-48f0-989c-a056d56876ee",
          publication_state: 'live',
          base_path: "/alpha-taxonomy/vehicle-plating",
          details: {
            internal_name: "Vehicle plating",
          }
        }
      )
    ]
  end

  def stubbed_topics
    [
      basic_content_item(
        "ID OF ALREADY TAGGED",
        other_fields: {
          document_type: 'topic',
          content_id: "ID-OF-ALREADY-TAGGED",
          publication_state: 'live',
          base_path: "/topic/id-of-already-tagged",
          details: {
            internal_name: "Test / Id of already tagged",
          }
        }
      ),
      basic_content_item(
        "Pension scheme administration",
        other_fields: {
          document_type: 'topic',
          content_id: "e1d6b771-a692-4812-a4e7-7562214286ef",
          publication_state: 'live',
          base_path: "/topic/business-tax/pension-scheme-administration",
          details: {
            internal_name: "Business tax / Pension scheme administration",
          }
        }
      )
    ]
  end

  def stubbed_organisations
    [
      basic_content_item(
        "Student Loans Company",
        other_fields: {
          document_type: 'organisation',
          content_id: "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
          publication_state: 'live',
          base_path: "/government/organisations/student-loans-company",
          details: {
            internal_name: "Student Loans Company",
          }
        }
      )
    ]
  end

  def stubbed_needs
    [
      basic_content_item(
        "As a user, I need to apply for a copy of a marriage certificate, so that I can prove identity and have a record of the marriage, or research my family history (100569)",
        other_fields: {
          document_type: 'need',
          content_id: "29e9fb40-69af-4c4c-bd56-02e3c825a63b",
          publication_state: 'live',
          base_path: "/needs/apply-for-a-copy-of-a-marriage-certificate",
          details: {
            internal_name: "As a user, I need to apply for a copy of a marriage certificate, so that I can prove identity and have a record of the marriage, or research my family history (100569)",
          }
        }
      )
    ]
  end

  def stubbed_mainstream_browse_pages
    [
      basic_content_item(
        "Vehicle tax and SORN",
        other_fields: {
          document_type: 'mainstream_browse_page',
          content_id: "d93d0cff-a035-4c49-8bc2-eaf6e040c42d",
          publication_state: 'live',
          base_path: "/browse/driving/car-tax-discs",
          details: {
            internal_name: "Driving and transport / Vehicle tax and SORN",
          }
        }
      )
    ]
  end
end
