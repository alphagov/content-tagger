class PublishTaxonWorker
  include Sidekiq::Worker
  BREXIT_TAXON_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

  def perform(taxon_content_id)
    Services.publishing_api.publish(taxon_content_id)

    if taxon_content_id == BREXIT_TAXON_CONTENT_ID
      Services.publishing_api.publish(taxon_content_id, nil, locale: "cy")
    end
  rescue GdsApi::HTTPConflict => e # Ignore attempts to publish already published content
    puts "409 #{e.message}"
  end
end
