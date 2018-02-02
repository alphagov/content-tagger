class CreateVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.string :content_id, null: false
      t.integer :number, null: false
      t.json :object_changes
      t.text :note

      t.index [:content_id, :number], unique: true

      t.timestamps null: false
    end
  end
end
