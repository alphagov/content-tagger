module BulkTagging
  class BuildTagMigration
    class InvalidArgumentError < ArgumentError; end

    attr_reader :original_link_content_id, :taxon_content_ids, :content_base_paths

    def initialize(original_link_content_id:, taxon_content_ids:, content_base_paths:)
      @original_link_content_id = original_link_content_id
      @taxon_content_ids = taxon_content_ids
      @content_base_paths = content_base_paths
    end

    def self.perform(original_link_content_id:, taxon_content_ids:, content_base_paths:)
      new(
        original_link_content_id: original_link_content_id,
        taxon_content_ids: taxon_content_ids,
        content_base_paths: content_base_paths
      ).perform
    end

    def perform
      validate_taxons
      validate_content_items

      taxon_content_ids.each do |taxon_content_id|
        expected_taxon = taxons.find { |taxon| taxon.content_id == taxon_content_id }
        create_tag_mappings_for_taxon(expected_taxon)
      end

      tag_migration
    end

  private

    def validate_taxons
      return if taxon_content_ids.present?

      raise InvalidArgumentError, I18n.t('bulk_tagging.update_tags.no_taxons')
    end

    def validate_content_items
      return if content_base_paths.present?

      raise InvalidArgumentError, I18n.t('bulk_tagging.update_tags.no_content_items')
    end

    def tag_migration
      @tag_migration ||= TagMigration.new(
        state: 'ready_to_import',
        original_link_content_id: original_link_content_id
      )
    end

    def create_tag_mappings_for_taxon(taxon)
      content_base_paths.each do |content_base_path|
        tag_mapping = BulkTagging::BuildTagMapping.perform(
          taxon: taxon,
          content_base_path: content_base_path
        )

        tag_migration.tag_mappings << tag_mapping
      end
    end

    def taxons
      @taxons ||= Taxonomy::TaxonFetcher.new.taxons
    end
  end
end
