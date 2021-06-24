module BulkTagging
  class QueueLinksForPublishing
    attr_reader :tagging_source, :tag_mappings, :user

    def self.call(tagging_source, user:)
      new(tagging_source, user: user).call
    end

    def initialize(tagging_source, user:)
      @tagging_source = tagging_source
      @tag_mappings = tagging_source.tag_mappings.order(id: :asc)
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        tagging_source.update!(
          last_published_at: Time.zone.now,
          last_published_by: user.uid,
          state: "imported",
        )

        tag_mappings.update_all(publish_requested_at: Time.zone.now)

        tag_mappings.each do |tag_mapping|
          PublishLinksWorker.perform_async(tag_mapping.id)
        end
      end
    end
  end
end
