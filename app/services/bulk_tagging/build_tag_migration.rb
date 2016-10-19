module BulkTagging
  class BuildTagMigration
    class InvalidArgumentError < ArgumentError; end

    attr_reader :source_content_item, :taxon_content_ids, :content_base_paths

    def initialize(source_content_item:, taxon_content_ids:, content_base_paths:)
      @source_content_item = source_content_item
      @taxon_content_ids = taxon_content_ids
      @content_base_paths = content_base_paths
    end

    def self.call(source_content_item:, taxon_content_ids:, content_base_paths:)
      new(
        source_content_item: source_content_item,
        taxon_content_ids: taxon_content_ids,
        content_base_paths: content_base_paths
      ).call
    end

    def call
      validate_taxons
      validate_content_items

      taxon_content_ids.each do |taxon_content_id|
        expected_taxon = ContentItem.find!(taxon_content_id)
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
        source_content_id: source_content_item.content_id,
        source_description: "#{source_content_item.title} (#{source_content_item.document_type.humanize})",
        source_title: source_content_item.title,
        source_document_type: source_content_item.document_type.humanize,
      )
    end

    def create_tag_mappings_for_taxon(taxon)
      content_base_paths.each do |content_base_path|
        tag_mapping = BulkTagging::BuildTagMapping.call(
          taxon: taxon,
          content_base_path: content_base_path
        )

        tag_migration.tag_mappings << tag_mapping
      end
    end
  end
end
