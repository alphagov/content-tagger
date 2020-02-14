class ContentItem
  attr_reader(
    :content_id,
    :title,
    :base_path,
    :description,
    :publishing_app,
    :rendering_app,
    :document_type,
    :state,
  )

  attr_writer :link_set

  def initialize(data, blacklist: Rails.configuration.blacklisted_tag_types)
    @blacklist = blacklist
    @content_id = data.fetch("content_id")
    @title = data.fetch("title")
    @base_path = data.fetch("base_path")
    @description = data.fetch("description", nil)
    @publishing_app = data.fetch("publishing_app", nil)
    @rendering_app = data.fetch("rendering_app", nil)
    @document_type = data.fetch("document_type")
    @state = data.fetch("state", nil)
  end

  def self.find!(content_id)
    content_item = Services.publishing_api.get_content(content_id)
    raise ItemNotFoundError if content_item["document_type"].in?(%w[redirect gone])

    new(content_item.to_h)
  rescue GdsApi::HTTPNotFound
    raise ItemNotFoundError
  end

  def draft?
    state == "draft"
  end

  def link_set
    @link_set ||= Tagging::ContentItemExpandedLinks.find(content_id)
  end

  def taxons?
    link_set.taxons.present?
  end

  def suggested_related_links?
    link_set.suggested_ordered_related_items.present?
  end

  def blacklisted_tag_types
    document_blacklist = Array(blacklist[publishing_app]).map(&:to_sym)
    document_blacklist += additional_temporary_blacklist

    unless related_links_are_renderable?
      document_blacklist += [:ordered_related_items]
    end

    unless taxons?
      document_blacklist += [:ordered_related_items_overrides]
    end

    unless suggested_related_links?
      document_blacklist += [:suggested_ordered_related_items]
    end

    document_blacklist
  end

  def allowed_tag_types
    Tagging::ContentItemExpandedLinks::TAG_TYPES - blacklisted_tag_types
  end

  class ItemNotFoundError < StandardError
  end

private

  attr_accessor :blacklist

  def related_links_are_renderable?
    %w[
      aaib_report
      answer
      asylum_support_decision
      authored_article
      business_finance_support_scheme
      calculator
      calendar
      case_study
      closed_consultation
      cma_case
      consultation
      consultation_outcome
      contact
      corporate_report
      correspondence
      countryside_stewardship_grant
      decision
      detailed_guidance
      detailed_guide
      dfid_research_output
      document_collection
      drug_safety_update
      employment_appeal_tribunal_decision
      employment_tribunal_decision
      esi_fund
      export_health_certificate
      foi_release
      form
      government_response
      guidance
      guide
      help_page
      impact_assessment
      independent_report
      international_development_fund
      international_treaty
      licence
      local_transaction
      maib_report
      map
      medical_safety_alert
      national_statistics
      news_article
      news_story
      notice
      official_statistics
      open_consultation
      oral_statement
      place
      policy_paper
      press_release
      programme
      promotional
      raib_report
      regulation
      research
      residential_property_tribunal_decision
      service_standard_report
      simple_smart_answer
      smart_answer
      specialist_document
      speech
      statistical_data_set
      statutory_guidance
      statutory_instrument
      tax_tribunal_decision
      transaction
      transparency
      travel_advice
      uk_market_conformity_assessment_body
      utaac_decision
      written_statement
    ].include?(document_type)
  end

  def additional_temporary_blacklist
    publishing_app == "specialist-publisher" && document_type == "finder" ? [:topics] : []
  end
end
