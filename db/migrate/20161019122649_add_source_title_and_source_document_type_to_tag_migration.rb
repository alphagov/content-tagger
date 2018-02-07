class AddSourceTitleAndSourceDocumentTypeToTagMigration < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_migrations, :source_title, :string
    add_column :tag_migrations, :source_document_type, :string
  end
end
