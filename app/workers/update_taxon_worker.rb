class UpdateTaxonWorker
  include Sidekiq::Worker
  include TransitionTaxon

  def perform(content_id, attributes)
    previous_taxon = Taxonomy::BuildTaxon.call(content_id: content_id)
    updated_taxon = previous_taxon.clone
    updated_taxon.assign_attributes(attributes)

    Taxonomy::SaveTaxonVersion.call(updated_taxon, "Bulk update", previous_taxon: previous_taxon)

    publishing_api_put_content_request(content_id, updated_taxon)
  end

private

  def payload(taxon, locale = "en")
    Taxonomy::BuildTaxonPayload.call(taxon: taxon, locale: locale)
  end

  def publishing_api_put_content_request(content_id, taxon)
    Services.publishing_api.put_content(content_id, payload(taxon))
    return unless brexit_taxon?(content_id)

    Services.publishing_api.put_content(content_id, payload(taxon, "cy"))
  end
end
