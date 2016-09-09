class AddOriginalLinkBasePathToTagMigrations < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :original_link_base_path, :string
  end
end
