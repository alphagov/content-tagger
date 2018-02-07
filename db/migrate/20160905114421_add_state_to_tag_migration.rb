class AddStateToTagMigration < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :state, :string
  end
end
