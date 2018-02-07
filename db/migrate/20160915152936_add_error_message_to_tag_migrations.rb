class AddErrorMessageToTagMigrations < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :error_message, :string
  end
end
