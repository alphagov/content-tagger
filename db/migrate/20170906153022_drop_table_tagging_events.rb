class DropTableTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    drop_table :tagging_events
  end
end
