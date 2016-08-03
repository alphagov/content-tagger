class PublishLinksWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(base_path, links_update)
    tag_mapping_ids = links_update.fetch("tag_mapping_ids")
    links_update.delete("tag_mapping_ids")

    # Return if the tag mappings have been deleted.
    tag_mappings = TagMapping.where(id: tag_mapping_ids)
    return if tag_mappings.count.zero?

    target_content_id = Services.publishing_api.lookup_content_id(base_path: base_path)
    return if target_content_id.blank?

    Services.publishing_api.patch_links(target_content_id, links: links_update)
    TagMapping.update_publish_completed_at(tag_mapping_ids)
  end
end
