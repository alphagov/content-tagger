class RenameAddedByToUserUidOnTaggingSpreadsheets < ActiveRecord::Migration
  def change
    rename_column :tagging_spreadsheets, :added_by, :user_uid
  end
end
