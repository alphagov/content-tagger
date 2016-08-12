class TaggingSpreadsheet < ActiveRecord::Base
  validates :url, presence: true
  validates(
    :state,
    presence: true,
    inclusion: { in: %w(uploaded errored ready_to_import imported) }
  )
  validates_with GoogleUrlValidator

  has_many :tag_mappings, dependent: :delete_all
  has_one :added_by, class_name: "User", primary_key: :user_uid, foreign_key: :uid

  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }

  def mark_as_deleted
    update(deleted_at: DateTime.current)
  end
end
