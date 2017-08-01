class PublishTaxonWorker
  include Sidekiq::Worker

  def perform(taxon_content_id)
    Services.publishing_api.publish(taxon_content_id)
  rescue GdsApi::HTTPConflict => ex # Ignore attempts to publish already published content
    puts "409 #{ex.message}"
  end
end
