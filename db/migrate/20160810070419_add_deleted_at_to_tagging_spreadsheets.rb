class AddDeletedAtToTaggingSpreadsheets < ActiveRecord::Migration
  def change
    add_column :tagging_spreadsheets, :deleted_at, :datetime
  end
end
