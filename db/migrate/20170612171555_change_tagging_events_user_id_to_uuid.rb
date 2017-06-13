class ChangeTaggingEventsUserIdToUuid < ActiveRecord::Migration[5.0]
  def change
    rename_column :tagging_events, :user_id, :user_uuid
  end
end
