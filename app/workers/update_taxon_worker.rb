class UpdateTaxonWorker
  include Sidekiq::Worker

  def perform(content_id, attributes)
    taxon = Taxonomy::BuildTaxon.call(content_id: content_id)
    taxon.phase = attributes.with_indifferent_access.fetch(:phase)

    payload = Taxonomy::BuildTaxonPayload.call(taxon: taxon)
    Services.publishing_api.put_content(content_id, payload)

    return unless taxon.published?

    Services.publishing_api.publish(content_id)
  end
end
