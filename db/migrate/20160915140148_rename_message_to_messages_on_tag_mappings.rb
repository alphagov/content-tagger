class RenameMessageToMessagesOnTagMappings < ActiveRecord::Migration
  def change
    rename_column :tag_mappings, :message, :messages
  end
end
