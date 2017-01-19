class PublishLinksWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(tag_mapping_id)
    tag_mapping = BulkTagging::TagMapping.find_by_id(tag_mapping_id)

    # In case the tag_mapping referenced by this job have been deleted by the
    # time the job runs.
    return if tag_mapping.blank?

    if tag_mapping.valid?(:update_links)
      BulkTagging::PublishLinks.call(tag_mapping: tag_mapping)
      tag_mapping.mark_as_tagged
    else
      tag_mapping.mark_as_errored
    end
  end
end
