module TagImporter
  class LinksPublisher
    attr_reader :links_update

    def self.publish(links_update:)
      new(links_update: links_update).publish
    end

    def initialize(links_update:)
      @links_update = links_update
    end

    def publish
      if links_update.valid?
        Services.publishing_api.patch_links(
          links_update.content_id,
          links: links_update.links_to_update
        )
        links_update.mark_as_tagged
      else
        links_update.mark_as_errored
      end
    end
  end
end
