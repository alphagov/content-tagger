class PublishTaxonWorker
  include Sidekiq::Worker

  def perform(taxon_content_id)
    Services.publishing_api.publish(taxon_content_id)
  rescue GdsApi::HTTPConflict => e # Ignore attempts to publish already published content
    Rails.logger.warn "409 #{e.message}"
  end
end
