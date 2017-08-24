module Taxonomy
  class UpdateTaxon
    attr_reader :taxon
    delegate :content_id, :parent, :associated_taxons, to: :taxon

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:)
      @taxon = taxon
    end

    def self.call(taxon:, validate: true)
      new(taxon: taxon).publish(validate: validate)
    end

    def publish(validate: true)
      if validate && !taxon.valid?
        raise "Invalid Taxon passed into UpdateTaxon: #{taxon.errors.full_messages}"
      end

      Services.publishing_api.put_content(content_id, payload)
      Services.publishing_api.patch_links(content_id, links: links)

    rescue GdsApi::HTTPUnprocessableEntity => e
      # Since we cannot easily differentiate the reasons for getting a 422
      # error code, we do a lookup to see if a content item with the slug
      # already exists, and if so, provide a more customised error message.
      existing_content_item = Services.publishing_api.lookup_content_id(
        base_path: taxon.base_path
      )

      if existing_content_item.nil?
        GovukError.notify(e)
        raise(InvalidTaxonError, I18n.t('errors.invalid_taxon'))
      else
        raise(InvalidTaxonError, I18n.t('errors.invalid_taxon_base_path'))
      end
    end

  private

    def payload
      Taxonomy::BuildTaxonPayload.call(taxon: taxon)
    end

    def links
      {
        parent_taxons: parent.empty? ? [] : Array(parent),
        associated_taxons: associated_taxons.blank? ? [] : Array(associated_taxons.reject(&:blank?)),
      }
    end
  end
end
