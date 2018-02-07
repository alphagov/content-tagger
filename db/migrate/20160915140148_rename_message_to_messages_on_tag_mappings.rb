class RenameMessageToMessagesOnTagMappings < ActiveRecord::Migration[4.2]
  def change
    rename_column :tag_mappings, :message, :messages
  end
end
