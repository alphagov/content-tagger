module BulkTagging
  class TaggingSpreadsheet < ApplicationRecord
    validates :url, presence: true
    validates(
      :state,
      presence: true,
      inclusion: { in: %w(uploaded errored ready_to_import imported) }
    )
    validates_with GoogleUrlValidator

    has_many :tag_mappings, dependent: :destroy, as: :tagging_source
    has_one :added_by, class_name: "User", primary_key: :user_uid, foreign_key: :uid

    scope :newest_first, -> { order(created_at: :desc) }
    scope :active, -> { where(deleted_at: nil) }

    def delete_source_link?
      false
    end

    def aggregated_tag_mappings
      AggregatableTagMappings.new(tag_mappings).aggregated_tag_mappings
    end

    def mark_as_deleted
      update(deleted_at: DateTime.current)
    end

    def error_count
      tag_mappings.errored.count
    end
  end
end
