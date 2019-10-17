class PublishTaxonWorker
  include Sidekiq::Worker
  include BrexitTaxon

  def perform(taxon_content_id)
    Services.publishing_api.publish(taxon_content_id)

    if brexit_taxon?(taxon_content_id)
      Services.publishing_api.publish(taxon_content_id, nil, locale: "cy")
    end
  rescue GdsApi::HTTPConflict => e # Ignore attempts to publish already published content
    puts "409 #{e.message}"
  end
end
