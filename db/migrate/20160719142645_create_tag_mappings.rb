class CreateTagMappings < ActiveRecord::Migration
  def change
    create_table :tag_mappings do |t|
      t.references :tagging_spreadsheet, index: true, foreign_key: true
      t.string :content_base_path
      t.string :link_title
      t.string :link_content_id
      t.string :link_type

      t.timestamps null: false
    end
  end
end
