class UpdateTaxonWorker
  include Sidekiq::Worker

  def perform(content_id, attributes)
    previous_taxon = Taxonomy::BuildTaxon.call(content_id: content_id)
    updated_taxon = previous_taxon.clone
    updated_taxon.assign_attributes(attributes)

    Taxonomy::SaveTaxonVersion.call(updated_taxon, "Bulk update", previous_taxon: previous_taxon)

    payload = Taxonomy::BuildTaxonPayload.call(taxon: updated_taxon)
    Services.publishing_api.put_content(content_id, payload)
  end
end
