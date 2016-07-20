module AlphaTaxonomy
  class TaxonLinkDeleter
    def initialize(logger: Logger.new(STDOUT), base_paths:)
      @log = logger
      @base_paths = base_paths
    end

    def run!
      @base_paths.each do |base_path|
        @log.info "Clearing links for #{base_path}"

        taxon_content_id = Services.publishing_api.lookup_content_id(base_path: base_path)
        if taxon_content_id.blank?
          raise ArgumentError, "No content ID found for base path #{base_path}"
        end

        linked_items = Services.publishing_api.get_linked_items(
          taxon_content_id, link_type: 'taxons', fields: %w(content_id base_path)
        )

        linked_items.each do |linked_item|
          @log.info "-- updated #{linked_item.fetch('base_path')}"
          Services.publishing_api.patch_links(
            linked_item.fetch("content_id"),
            links: { taxons: [] }
          )
        end
      end
    end
  end
end
