class UseSourceDescriptionForTagMigrations < ActiveRecord::Migration
  def change
    remove_column :tag_migrations, :document_type, :string
    remove_column :tag_migrations, :source_base_path, :string
    remove_column :tag_migrations, :query, :string
    add_column :tag_migrations, :source_description, :text
  end
end
