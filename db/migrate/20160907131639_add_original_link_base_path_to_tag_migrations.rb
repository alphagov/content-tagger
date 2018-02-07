class AddOriginalLinkBasePathToTagMigrations < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :original_link_base_path, :string
  end
end
