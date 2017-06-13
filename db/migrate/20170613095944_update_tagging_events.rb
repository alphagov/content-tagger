class UpdateTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :tagging_events, :taxon_content_title, :taxon_title
    rename_column :tagging_events, :content_id, :taggable_content_id
    rename_column :tagging_events, :content_title, :taggable_title
    rename_column :tagging_events, :user_id, :user_uid
    remove_column :tagging_events, :user_email, :string
  end
end
