class ModifyForeignKeyOnTagMappings < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :tag_mappings, :tagging_spreadsheets
    add_foreign_key :tag_mappings, :tagging_spreadsheets, on_delete: :cascade
  end
end
