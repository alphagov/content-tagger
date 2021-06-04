module DataExport
  class ContentExport
    CONTENT_BASE_FIELDS = %w[base_path content_id document_type first_published_at locale publishing_app title description details].freeze
    CONTENT_TAXON_FIELDS = %w[title content_id].freeze
    CONTENT_PPO_FIELDS = %w[title].freeze
    BLACKLIST_DOCUMENT_TYPES = %w[
      staff_update
      coming_soon
      travel_advice
      html_publication
      manual_section
      hmrc_manual_section
      contact
      completed_transaction
      aaib_report
      raib_report
      maib_report
      service_standard_report
      employment_tribunal_decision
      tax_tribunal_decision
      utaac_decision
      dfid_research_output
      asylum_support_decision
      employment_appeal_tribunal_decision
      cma_case
      need
      working_group
      organisation
      person
      worldwide_organisation
      world_location
      topical_event
      policy_area
      field_of_operation
      ministerial_role
      topical_event_about_page
      finder_email_signup
      mainstream_browse_page
      topic
      homepage
      licence_finder
      search
      taxon
      travel_advice_index
      business_support_finder
      finder
      about
      about_our_services
      personal_information_charter
      equality_and_diversity
      our_governance
      services_and_information
      our_energy_use
      corporate_report
      social_media_use
      access_and_opening
      membership
      publication_scheme
      media_enquiries
      complaints_procedure
      help_page
      service_manual_homepage
      service_manual_service_toolkit
      service_manual_service_standard
      service_manual_guide
      service_manual_topic
      gone
      redirect
    ].freeze

    def content_links_enum(page_size = 1000)
      Services.search_api.search_enum(
        { reject_content_store_document_type: BLACKLIST_DOCUMENT_TYPES, fields: %w[link] },
        page_size: page_size,
      ).lazy.map { |h| h["link"] }
    end

    def get_content(base_path, base_fields: CONTENT_BASE_FIELDS, taxon_fields: CONTENT_TAXON_FIELDS, ppo_fields: CONTENT_PPO_FIELDS)
      hash = get_content_hash(base_path)

      # Skip this if we don't get back the content we expect, e.g. if
      # the Content Store has redirected the request
      return {} if hash["base_path"] != base_path

      # Skip anything without a content_id
      return {} if hash["content_id"].nil?

      base = hash.slice(*base_fields)
      taxons = hash.dig("links", "taxons")
      ppo = hash.dig("links", "primary_publishing_organisation")
      base.tap do |result|
        result["taxons"] = taxons.map { |t| t.slice(*taxon_fields) } if taxons.present?
        result["primary_publishing_organisation"] = ppo.first.slice(*ppo_fields) if ppo.present?
      end
    rescue GdsApi::ContentStore::ItemNotFound
      Rails.logger.warn("Cannot find content item '#{base_path}' in the content store")
      {}
    rescue StandardError => e
      Rails.logger.warn("Error processing '#{base_path}': #{e.message}")
      {}
    end

    def blacklisted_content_stats(document_types = ContentExport::BLACKLIST_DOCUMENT_TYPES)
      filtered_aggregates = document_aggregates.keep_if do |aggregate|
        document_types.include?(aggregate.dig("value", "slug"))
      end
      results = filtered_aggregates.map do |aggregate|
        { document_type: aggregate.dig("value", "slug"),
          count: aggregate["documents"] }
      end
      results.sort_by { |r| -r[:count] }
    end

  private

    def document_aggregates
      Services.search_api.search(aggregate_content_store_document_type: 10_000, count: 0)
        .dig("aggregates", "content_store_document_type", "options")
    end

    def get_content_hash(path)
      Services.content_store.content_item(path).to_h
    end
  end
end
