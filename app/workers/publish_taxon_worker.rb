class PublishTaxonWorker
  include Sidekiq::Worker
  include TransitionTaxon

  def perform(taxon_content_id)
    Services.publishing_api.publish(taxon_content_id)

    if transition_taxon?(taxon_content_id)
      Services.publishing_api.publish(taxon_content_id, nil, locale: "cy")
    end
  rescue GdsApi::HTTPConflict => e # Ignore attempts to publish already published content
    Rails.logger.warn "409 #{e.message}"
  end
end
