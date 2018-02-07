class RenameOriginalLinkToSource < ActiveRecord::Migration[4.2]
  def change
    rename_column :tag_migrations, :original_link_content_id, :source_content_id
    rename_column :tag_migrations, :original_link_base_path, :source_base_path
  end
end
