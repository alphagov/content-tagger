module Taxonomy
  class UpdateTaxon
    attr_reader :taxon

    delegate :content_id, :parent_content_id, :associated_taxons, to: :taxon

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:, version_note:)
      @taxon = taxon
      @version_note = version_note
    end

    def self.call(taxon:, validate: true, version_note: nil)
      new(taxon:, version_note:).publish(validate:)
    end

    def publish(validate: true)
      if validate && !taxon.valid?
        raise "Invalid Taxon passed into UpdateTaxon: #{taxon.errors.full_messages}"
      end

      # We need to get a snapshot of the taxon, before the PUT request is made,
      # so that we can compare the differences between the two versions.
      Taxonomy::SaveTaxonVersion.call(taxon, @version_note)

      publishing_api_put_content_request(content_id)

      Taxonomy::LinksUpdate.new(
        content_id:,
        parent_taxon_id: parent_content_id,
        associated_taxon_ids: associated_taxons,
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
        error_message = I18n.t("errors.invalid_taxon_base_path", taxon_path:)
        raise(InvalidTaxonError, ActionController::Base.helpers.sanitize(error_message))
      else
        GovukError.notify(e)
        raise(InvalidTaxonError, I18n.t("errors.invalid_taxon"))
      end
    end

  private

    def payload(locale = "en")
      Taxonomy::BuildTaxonPayload.call(taxon:, locale:)
    end

    def publishing_api_put_content_request(content_id)
      Services.publishing_api.put_content(content_id, payload)
    end
  end
end
