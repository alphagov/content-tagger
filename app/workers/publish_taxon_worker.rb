class PublishTaxonWorker
  include Sidekiq::Worker

  def perform(taxon)
    Taxonomy::PublishTaxon.call(taxon)
  rescue GdsApi::HTTPConflict => ex # Ignore attempts to publish already published content
    puts "409 #{ex.message}"
  end
end
