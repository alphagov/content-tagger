class LookupContentIdWorker
  include Sidekiq::Worker

  def perform(project_content_item_id)
    content_item = ProjectContentItem.find(project_content_item_id)
    id = Services.publishing_api.lookup_content_id(base_path: content_item.base_path)
    content_item.update_attribute(:content_id, id)
  rescue ActiveRecord::RecordNotFound => ex
    # This is to prevent a lot of retries when a project is deleted before instances of this worker are finished.
    logger.info ex.message
  end
end
