class AddDeletedAtToTagMigrations < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :deleted_at, :datetime
  end
end
