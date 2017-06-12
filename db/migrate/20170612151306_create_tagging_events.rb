class CreateTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :tagging_events do |t|
      t.uuid :taxon_content_id, null: false
      t.string :taxon_content_title, null: false

      t.uuid :content_id, null: false
      t.string :content_title, null: false

      t.uuid :user_id, null: false
      t.string :user_email, null: false

      t.date :tagged_on, null: false
      t.timestamp :tagged_at, null: false

      t.integer :change, null: false

      t.timestamps
    end

    add_index :tagging_events, :tagged_on
    add_index :tagging_events, :taxon_content_id
    add_index :tagging_events, :content_id
  end
end
