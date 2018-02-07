class AddDeletedAtToTagMigrations < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :deleted_at, :datetime
  end
end
