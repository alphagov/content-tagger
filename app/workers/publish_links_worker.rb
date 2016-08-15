class PublishLinksWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(base_path, links_update)
    tag_mapping_ids = links_update.delete('tag_mapping_ids')
    tag_mappings = TagMapping.where(id: tag_mapping_ids)

    TagImporter::LinksPublisher.publish(
      base_path: base_path,
      tag_mappings: tag_mappings,
      links: links_update
    )
  end
end
