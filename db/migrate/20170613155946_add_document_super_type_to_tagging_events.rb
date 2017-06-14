class AddDocumentSuperTypeToTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    execute 'DELETE FROM tagging_events'
    add_column :tagging_events, :taggable_navigation_document_supertype, :string, null: false
    add_column :tagging_events, :taggable_base_path, :string, null: false
  end
end
