class UpdateTaxonWorker
  include Sidekiq::Worker

  def perform(content_id, payload)
    taxon = Services.publishing_api.get_content(content_id)

    Services.publishing_api.put_content(content_id, payload)

    return unless taxon.to_h['publication_state'] == 'published'

    Services.publishing_api.publish(content_id)
  end
end
