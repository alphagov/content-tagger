class DeleteForeignKeyInTagMappings < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :tag_mappings, column: :tagging_source_id
  end
end
