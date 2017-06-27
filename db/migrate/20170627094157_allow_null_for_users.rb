class AllowNullForUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :tagging_events, :user_uid, :uuid, null: true
  end
end
