class TagMapping < ActiveRecord::Base
  belongs_to :tagging_spreadsheet
  scope :by_content_base_path, -> { order(content_base_path: :asc) }
  scope :by_link_title, -> { order(link_title: :asc) }
end
