class UpdateTaxonWorker
  include Sidekiq::Worker

  def perform(content_id, payload)
    Services.publishing_api.put_content(content_id, payload)
  end
end
