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
    ].freeze

    def content_links_enum(window = 1000, size = Float::INFINITY)
      Enumerator.new do |yielder|
        (0..size).step(window).each do |index|
          results = Services.rummager.search(start: index.to_i,
                                             count: window,
                                             reject_content_store_document_type: BLACKLIST_DOCUMENT_TYPES,
                                             fields: ['link']).to_h.fetch('results', [])
          results.each do |result|
            yielder << result['link']
          end
          if results.count < window
            break
          end
        end
      end
    end

    def get_content(base_path, base_fields: CONTENT_BASE_FIELDS, taxon_fields: CONTENT_TAXON_FIELDS, ppo_fields: CONTENT_PPO_FIELDS)
      hash = get_content_hash(base_path)
      base = hash.slice(*base_fields)
      taxons = hash.dig('links', 'taxons')
      ppo = hash.dig('links', 'primary_publishing_organisation')
      base.tap do |result|
        result['taxons'] = taxons.map { |t| t.slice(*taxon_fields) } if taxons.present?
        result['primary_publishing_organisation'] = ppo.first.slice(*ppo_fields) if ppo.present?
      end
    rescue GdsApi::ContentStore::ItemNotFound
      Rails.logger.warn("Cannot find content item '#{base_path}' in the content store")
      {}
    rescue StandardError => ex
      Rails.logger.warn("Error processing '#{base_path}': #{ex.message}")
      {}
    end

  private

    def get_content_hash(path)
      Services.content_store.content_item(path).to_h
    end
  end
end
