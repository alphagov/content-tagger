module Taxonomy
  class Publisher
    attr_reader :taxon
    delegate :content_id, :parent_taxons, to: :taxon

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:)
      @taxon = taxon
    end

    def self.publish(taxon:)
      new(taxon: taxon).publish
    end

    def publish
      Services.publishing_api.put_content(content_id, presenter.payload)
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

    def presenter
      Taxonomy::TaxonPayloadBuilder.new(taxon)
    end
  end
end
