class TagMigration < ActiveRecord::Base
  include AggregatableTagMappings

  has_many :tag_mappings, dependent: :destroy, as: :tagging_source
  validates :source_content_id, presence: true

  validates(
    :state,
    presence: true,
    inclusion: { in: %w(ready_to_import imported errored) }
  )

  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }

  def mark_as_deleted
    update!(deleted_at: DateTime.current)
  end

  def error_count
    tag_mappings.errored.count
  end
end
