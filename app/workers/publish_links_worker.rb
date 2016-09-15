class PublishLinksWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(base_path, links)
    tag_mapping_ids = links.delete('tag_mapping_ids')
    tag_mappings = TagMapping.where(id: tag_mapping_ids)

    links_update = LinksUpdate.new(
      base_path: base_path,
      tag_mappings: tag_mappings,
      links: links
    )

    # In case the tag_mappings referenced by this job have been deleted by the
    # time the job runs.
    return if links_update.tag_mappings.empty?

    LinksPublisher.publish(links_update: links_update)
  end
end
