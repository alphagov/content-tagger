module TagImporter
  class LinksPublisher
    attr_reader :base_path, :tag_mappings, :links
    attr_accessor :reason

    def self.publish(base_path:, tag_mappings:, links:)
      new(
        base_path: base_path,
        tag_mappings: tag_mappings,
        links: links,
      ).publish
    end

    def initialize(base_path:, tag_mappings:, links:)
      @base_path = base_path
      @tag_mappings = tag_mappings
      @links = links
    end

    def publish
      if valid?
        tag_mappings.update_all(
          state: 'tagged',
          publish_completed_at: Time.current
        )

        Services.publishing_api.patch_links(target_content_id, links: links)
        return true
      else
        tag_mappings.update_all(state: :errored, message: reason)
        return false
      end
    end

    def valid?
      tag_mappings.count > 0 &&
        valid_content_id? &&
        valid_link_type? &&
        valid_taxons?
    end

  private

    def reason
      return if tag_mappings.empty?
      return I18n.t('tag_import.errors.invalid_content_id') unless valid_content_id?
      return I18n.t('tag_import.errors.invalid_link_types') unless valid_link_type?
      return I18n.t('tag_import.errors.invalid_taxons_found') unless valid_taxons?

      nil
    end

    def valid_link_type?
      links.keys == ['taxons']
    end

    def valid_content_id?
      !target_content_id.blank?
    end

    def valid_taxons?
      return true if taxons.empty?

      (taxons - known_taxon_content_ids).empty?
    end

    def target_content_id
      @target_content_id ||=
        Services.publishing_api.lookup_content_id(base_path: base_path)
    end

    def known_taxon_content_ids
      Taxonomy::TaxonFetcher.new.taxon_content_ids
    end

    def taxons
      @taxons ||= links.fetch('taxons', [])
    end
  end
end
