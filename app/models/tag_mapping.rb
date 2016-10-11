class TagMapping < ActiveRecord::Base
  belongs_to :tagging_source, polymorphic: true

  scope :completed, -> { where(state: %w(tagged errored)) }
  scope :errored, -> { where(state: :errored) }
  scope :by_content_base_path, -> { order(content_base_path: :asc) }
  scope :by_link_title, -> { order(link_title: :asc) }
  scope :by_state, -> { order(state: :asc) }

  serialize :messages, Array

  validates(
    :state,
    presence: true,
    inclusion: { in: %w(ready_to_tag tagged errored) }
  )
  validates_with ContentIdValidator, on: :update_links
  validates_with LinkTypeValidator, on: :update_links

  def content_id
    @content_id ||=
      Services.publishing_api.lookup_content_id(base_path: content_base_path)
  end

  def mark_as_tagged
    update(state: 'tagged', publish_completed_at: Time.current)
  end

  def mark_as_errored
    return if errors.messages.blank?

    update(
      state: :errored,
      messages: errors.messages.values.flatten
    )

    tagging_source.update(
      state: :errored,
      error_message: I18n.t('tag_import.errors.tag_mappings_failed')
    )
  end
end
