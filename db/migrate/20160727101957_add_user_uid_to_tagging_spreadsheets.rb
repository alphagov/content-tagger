class AddUserUidToTaggingSpreadsheets < ActiveRecord::Migration[4.2]
  def change
    add_column :tagging_spreadsheets, :added_by, :string
    add_column :tagging_spreadsheets, :last_published_by, :string
    add_column :tagging_spreadsheets, :last_published_at, :datetime
  end
end
