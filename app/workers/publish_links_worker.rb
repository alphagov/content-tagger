class PublishLinksWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  sidekiq_retries_exhausted do |msg, _e|
    tag_mapping_id = msg["args"].first

    BulkTagging::TagMapping.connection_pool.with_connection do |_conn|
      tag_mapping = BulkTagging::TagMapping.find_by_id(tag_mapping_id)

      tag_mapping.errors.add(:base, "Unable to publish taxon changes")
      tag_mapping.mark_as_errored
    end
  end

  def perform(tag_mapping_id)
    tag_mapping = BulkTagging::TagMapping.find_by_id(tag_mapping_id)

    # In case the tag_mapping referenced by this job have been deleted by the
    # time the job runs.
    return if tag_mapping.blank?

    if tag_mapping.valid?(:update_links)
      attempts = 0
      begin
        attempts += 1
        BulkTagging::PublishLinks.call(tag_mapping:)
        tag_mapping.mark_as_tagged
      rescue GdsApi::HTTPConflict => e
        # If multiple jobs reference the same content_id then some will fail
        # with a lock version conflict. We can safely retry such jobs since
        # they always fetch the latest version before updating links. We catch
        # the exception to prevent it being reported, but then need to retry
        # manually since Sidekiq won't see it. After 5 retries we re-raise the
        # exception and let Sidekiq handle it.
        raise e if attempts >= 5

        retry
      end
    else
      tag_mapping.mark_as_errored
    end
  end
end
