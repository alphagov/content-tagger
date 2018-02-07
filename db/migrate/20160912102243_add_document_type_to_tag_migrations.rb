class AddDocumentTypeToTagMigrations < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :document_type, :string
  end
end
