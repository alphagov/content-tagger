class AddDescriptionToTaggingSpreadsheet < ActiveRecord::Migration[4.2]
  def change
    add_column :tagging_spreadsheets, :description, :string
  end
end
