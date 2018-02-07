class AddStateToTaggingSpreadsheets < ActiveRecord::Migration[4.2]
  def change
    # At this point in development we can just clear out all the spreadsheets
    # so we don't have to bother with setting an initial state.
    BulkTagging::TaggingSpreadsheet.delete_all
    add_column :tagging_spreadsheets, :state, :string, null: false
    add_column :tagging_spreadsheets, :error_message, :text
  end
end
