class RenameAddedByToUserUidOnTaggingSpreadsheets < ActiveRecord::Migration[4.2]
  def change
    rename_column :tagging_spreadsheets, :added_by, :user_uid
  end
end
