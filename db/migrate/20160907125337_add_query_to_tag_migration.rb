class AddQueryToTagMigration < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :query, :string
  end
end
