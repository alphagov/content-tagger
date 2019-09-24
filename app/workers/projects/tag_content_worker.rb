module Projects
  class TagContentWorker
    include Sidekiq::Worker

    def perform(content_item_id, taxon_content_ids)
      Services.publishing_api
        .patch_links(
          content_item_id,
          links: { taxons: taxon_content_ids },
        )
    end
  end
end
