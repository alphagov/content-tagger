module Taxonomy
  class UpdateTaxon
    attr_reader :taxon
    delegate :content_id, :parent_content_id, :associated_taxons, :legacy_taxons, to: :taxon

    BREXIT_TAXON_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:, version_note:)
      @taxon = taxon
      @version_note = version_note
    end

    def self.call(taxon:, validate: true, version_note: nil)
      new(taxon: taxon, version_note: version_note).publish(validate: validate)
    end

    def publish(validate: true)
      if validate && !taxon.valid?
        raise "Invalid Taxon passed into UpdateTaxon: #{taxon.errors.full_messages}"
      end

      # We need to get a snapshot of the taxon, before the PUT request is made,
      # so that we can compare the differences between the two versions.
      Taxonomy::SaveTaxonVersion.call(taxon, @version_note)

      Services.publishing_api.put_content(content_id, payload)
      if content_id == BREXIT_TAXON_CONTENT_ID
        Services.publishing_api.put_content(content_id, payload("cy"))
      end

      Taxonomy::LinksUpdate.new(
        content_id: content_id,
        parent_taxon_id: parent_content_id,
        associated_taxon_ids: associated_taxons,
        legacy_taxon_ids: legacy_taxon_ids,
      ).call
    rescue GdsApi::HTTPUnprocessableEntity => e
      # Since we cannot easily differentiate the reasons for getting a 422
      # error code, we do a lookup to see if a content item with the slug
      # already exists, and if so, provide a more customised error message.
      existing_content_id = Services.publishing_api.lookup_content_id(
        base_path: taxon.base_path,
        with_drafts: true,
      )

      if existing_content_id.present? && existing_content_id != taxon.content_id
        taxon_path = Rails.application.routes.url_helpers.taxon_path(existing_content_id)
        error_message = I18n.t("errors.invalid_taxon_base_path", taxon_path: taxon_path)
        raise(InvalidTaxonError, ActionController::Base.helpers.sanitize(error_message))
      else
        GovukError.notify(e)
        raise(InvalidTaxonError, I18n.t("errors.invalid_taxon"))
      end
    end

  private

    def payload(locale = "en")
      Taxonomy::BuildTaxonPayload.call(taxon: taxon, locale: locale)
    end

    def legacy_taxon_ids
      return [] if taxon.legacy_taxons.blank?

      Array(
        Tagging::BasePathLookup.find_by_base_paths(taxon.legacy_taxons),
      ).select(&:present?).map(&:content_id)
    end
  end
end
