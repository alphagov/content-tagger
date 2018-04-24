module LegacyTaxonomy
  class TaxonData
    attr_accessor(
      :title,
      :internal_name,
      :description,
      :legacy_content_id,
      :path_slug,
      :path_prefix,
    )
    attr_writer(:child_taxons, :tagged_pages)

    include ActiveModel::Model

    def child_taxons
      @child_taxons || []
    end

    def base_path
      path_prefix + path_slug
    end

    def tagged_pages
      @tagged_pages || []
    end

    def content_id
      @_content_id ||= begin
        Client::PublishingApi.content_id_for_base_path(base_path) || SecureRandom.uuid
      end
    end

    def hash_for_publishing_api
      {
        title: title,
        internal_name: internal_name,
        description: description,
        base_path: base_path,
        content_id: content_id
      }
    end

    def to_stats_hash
      {
        title: title,
        description: description,
        base_path: base_path,
        tagged_count: tagged_pages.count
      }
    end
  end
end
