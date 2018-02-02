class Version < ActiveRecord::Base
  scope :history, ->(content_id) { where(content_id: content_id).order(number: :desc) }

  before_create :increment_number

  def self.latest_version(content_id)
    history(content_id).first
  end

private

  def increment_number
    previous_revision = Version.latest_version(content_id)
    self.number = previous_revision.present? ? previous_revision.number + 1 : 1
  end
end
