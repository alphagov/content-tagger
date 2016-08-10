class AddDescriptionToTaggingSpreadsheet < ActiveRecord::Migration
  def change
    add_column :tagging_spreadsheets, :description, :string
  end
end
