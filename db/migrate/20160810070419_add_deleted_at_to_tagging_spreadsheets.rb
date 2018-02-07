class AddDeletedAtToTaggingSpreadsheets < ActiveRecord::Migration[4.2]
  def change
    add_column :tagging_spreadsheets, :deleted_at, :datetime
  end
end
