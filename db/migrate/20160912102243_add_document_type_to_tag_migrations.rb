class AddDocumentTypeToTagMigrations < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :document_type, :string
  end
end
