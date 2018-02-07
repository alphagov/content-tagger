class AddStateAndMessageToTagMappings < ActiveRecord::Migration[4.2]
  def change
    BulkTagging::TagMapping.delete_all
    add_column :tag_mappings, :state, :string, null: false
    add_column :tag_mappings, :message, :string
  end
end
