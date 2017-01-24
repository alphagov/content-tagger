module Taxonomy
  class PublishTaxon
    attr_reader :taxon
    delegate :content_id, :parent_taxons, to: :taxon

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:)
      @taxon = taxon
    end

    def self.call(taxon:, validate: true)
      new(taxon: taxon).publish(validate: validate)
    end

    def publish(validate: true)
      raise "Invalid Taxon passed into PublishTaxon" if validate && !taxon.valid?

      Services.publishing_api.put_content(content_id, payload)
      Services.publishing_api.publish(content_id, "minor")
      Services.publishing_api.patch_links(
        content_id,
        links: { parent_taxons: parent_taxons.select(&:present?) }
      )
    rescue GdsApi::HTTPUnprocessableEntity => e
      Airbrake.notify(e)
      raise(InvalidTaxonError, I18n.t('errors.invalid_taxon'))
    end

  private

    def payload
      Taxonomy::BuildTaxonPayload.call(taxon: taxon)
    end
  end
end
