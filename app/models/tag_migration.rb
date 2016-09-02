class TagMigration < ActiveRecord::Base
  has_many :tag_mappings, dependent: :destroy, as: :tagging_source
  validates :original_link_content_id, presence: true

  validates(
    :state,
    presence: true,
    inclusion: { in: %w(ready_to_import imported) }
  )

  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }

  def mark_as_deleted
    update!(deleted_at: DateTime.current)
  end
end
