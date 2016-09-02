class AddOriginalLinkContentIdToTagMigrations < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :original_link_content_id, :string
  end
end
