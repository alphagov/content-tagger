class AddStateToTagMigration < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :state, :string
  end
end
