class TagMapping < ActiveRecord::Base
  belongs_to :tagging_spreadsheet
  scope :by_content_base_path, -> { order(content_base_path: :asc) }
  scope :by_link_title, -> { order(link_title: :asc) }

  validates(
    :state,
    presence: true,
    inclusion: { in: %w(ready_to_tag tagged errored) }
  )

  def self.publish_confirmed
    where("publish_requested_at < publish_completed_at")
  end

  def publish_confirmed?
    return false unless publish_requested_at
    publish_requested_at <= (publish_completed_at || DateTime.new(0))
  end
end
