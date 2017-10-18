class SetColumnsToNotNull < ActiveRecord::Migration
  def change
    BulkTagging::TaggingSpreadsheet.delete_all

    change_column_null :tag_mappings, :tagging_spreadsheet_id, false
    change_column_null :tag_mappings, :content_base_path, false
    change_column_null :tag_mappings, :link_content_id, false
    change_column_null :tag_mappings, :link_type, false

    change_column_null :tagging_spreadsheets, :user_uid, false
  end
end
