class AddLastPublishedTimestampFieldsToTagMigration < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :last_published_at, :datetime
    add_column :tag_migrations, :last_published_by, :string
  end
end
