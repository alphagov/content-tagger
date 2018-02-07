class AddQueryToTagMigration < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :query, :string
  end
end
