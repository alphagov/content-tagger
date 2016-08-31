class TagMapping < ActiveRecord::Base
  belongs_to :tagging_spreadsheet
  scope :completed, -> { where(state: %w(tagged errored)) }
  scope :by_content_base_path, -> { order(content_base_path: :asc) }
  scope :by_link_title, -> { order(link_title: :asc) }
  scope :by_state, -> { order(state: :asc) }

  validates(
    :state,
    presence: true,
    inclusion: { in: %w(ready_to_tag tagged errored) }
  )
end
