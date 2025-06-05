module BulkTagging
  class TagMapping < ApplicationRecord
    belongs_to :tagging_source, polymorphic: true

    COMPLETED_STATES = %w[tagged errored].freeze

    scope :completed, -> { where(state: COMPLETED_STATES) }
    scope :errored, -> { where(state: :errored) }
    scope :by_content_base_path, -> { order(content_base_path: :asc) }
    scope :by_link_title, -> { order(link_title: :asc) }
    scope :by_state, -> { order(state: :asc) }

    serialize :messages, coder: YAML, type: Array

    validates(
      :state,
      presence: true,
      inclusion: { in: %w[ready_to_tag tagged errored] },
    )
    validates_with ContentIdValidator, on: :update_links
    validates_with LinkTypeValidator, on: :update_links

    delegate :delete_source_link?, to: :tagging_source, prefix: false

    def content_id
      @content_id ||=
        Services.publishing_api.lookup_content_id(base_path: content_base_path, exclude_unpublishing_types: %w[vanish gone], exclude_document_types: %w[gone])
    end

    def mark_as_tagged
      update(state: "tagged", publish_completed_at: Time.zone.now)
    end

    def mark_as_errored
      return if errors.messages.blank?

      update!(
        state: :errored,
        messages: errors.messages.values.flatten,
      )

      tagging_source.update!(
        state: :errored,
        error_message: I18n.t("tag_import.errors.tag_mappings_failed"),
      )
    end
  end
end
