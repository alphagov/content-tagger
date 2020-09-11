module BulkTagging
  class TagMigration < ApplicationRecord
    has_many :tag_mappings, dependent: :destroy, as: :tagging_source
    validates :source_content_id, :source_title, :source_document_type, presence: true

    validates(
      :state,
      presence: true,
      inclusion: { in: %w[ready_to_import imported errored] },
    )

    scope :newest_first, -> { order(created_at: :desc) }
    scope :active, -> { where(deleted_at: nil) }

    def source_description
      "#{source_title} (#{source_document_type})"
    end

    def aggregated_tag_mappings
      AggregatableTagMappings.new(tag_mappings).aggregated_tag_mappings
    end

    def should_delete_source_link?
      ready_to_import? && delete_source_link?
    end

    def mark_as_deleted
      update!(deleted_at: Time.zone.now)
    end

    def error_count
      tag_mappings.errored.count
    end

    def ready_to_import?
      state == "ready_to_import"
    end

    def errored?
      state == "errored"
    end
  end
end
