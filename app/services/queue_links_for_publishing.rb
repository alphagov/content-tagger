class QueueLinksForPublishing
  attr_reader :tagging_spreadsheet
  attr_reader :tag_mappings
  attr_reader :user

  def self.call(tagging_spreadsheet, user:)
    new(tagging_spreadsheet, user: user).call
  end

  def initialize(tagging_spreadsheet, user:)
    @tagging_spreadsheet = tagging_spreadsheet
    @tag_mappings = tagging_spreadsheet.tag_mappings.order(id: :asc)
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      tagging_spreadsheet.update!(
        last_published_at: Time.zone.now,
        last_published_by: user.uid,
        state: "imported"
      )

      tag_mappings.update_all(publish_requested_at: Time.zone.now)

      tag_mappings.each do |tag_mapping|
        PublishLinksWorker.perform_async(tag_mapping.id)
      end
    end
  end
end
