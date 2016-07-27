class CreateTaggingSpreadsheets < ActiveRecord::Migration
  def change
    create_table :tagging_spreadsheets do |t|
      t.string :url, null: false

      t.timestamps null: false
    end
  end
end
