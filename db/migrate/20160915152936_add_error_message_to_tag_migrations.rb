class AddErrorMessageToTagMigrations < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :error_message, :string
  end
end
