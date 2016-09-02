class AddLastPublishedTimestampFieldsToTagMigration < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :last_published_at, :datetime
    add_column :tag_migrations, :last_published_by, :string
  end
end
