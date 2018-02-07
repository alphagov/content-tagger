class CreateTaggingSpreadsheets < ActiveRecord::Migration[4.2]
  def change
    create_table :tagging_spreadsheets do |t|
      t.string :url, null: false

      t.timestamps null: false
    end
  end
end
