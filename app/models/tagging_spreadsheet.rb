class TaggingSpreadsheet < ActiveRecord::Base
  validates :url, presence: true
  has_many :tag_mappings, dependent: :delete_all
  scope :newest_first, -> { order(created_at: :desc) }
end
