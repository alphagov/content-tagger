class TaggingSpreadsheet < ActiveRecord::Base
  validates :url, presence: true
  validates(
    :state,
    presence: true,
    inclusion: { in: %w(uploaded errored ready_to_import imported) }
  )
  validates_with GoogleUrlValidator

  has_many :tag_mappings, dependent: :destroy, as: :tagging_source
  has_one :added_by, class_name: "User", primary_key: :user_uid, foreign_key: :uid

  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }

  def mark_as_deleted
    update(deleted_at: DateTime.current)
  end

  def error_count
    tag_mappings.errored.count
  end

  def aggregated_tag_mappings
    aggregated_tag_mappings = []

    tag_mappings_grouped_by_content_base_path.reduce([]) do |acc, aggregation|
      aggregated_tag_mappings << AggregatedTagMapping.new(content_base_path: aggregation.first, tag_mappings: aggregation.last)
    end

    aggregated_tag_mappings
  end

private
  def tag_mappings_grouped_by_content_base_path
    tag_mappings.by_state.by_content_base_path.by_link_title.
      select(
        :id,
        :link_type,
        :link_title,
        :content_base_path,
        :message,
        :link_content_id,
        :state).
      group_by(&:content_base_path)
  end
end
