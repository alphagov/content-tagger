class TagMigration < ActiveRecord::Base
  has_many :tag_mappings, dependent: :delete_all, as: :tagging_source
  validates :original_link_content_id, presence: true
end
