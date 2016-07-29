module Taxonomy
  class Publisher
    attr_reader :taxon_form
    delegate :content_id, :parent_taxons, to: :taxon_form

    class InvalidTaxonError < StandardError; end

    def initialize(taxon_form:)
      @taxon_form = taxon_form
    end

    def self.publish(taxon_form:)
      new(taxon_form: taxon_form).publish
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
      TaxonPresenter.new(taxon_form)
    end
  end
end
