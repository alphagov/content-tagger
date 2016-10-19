class AddSourceTitleAndSourceDocumentTypeToTagMigration < ActiveRecord::Migration
  def change
    add_column :tag_migrations, :source_title, :string
    add_column :tag_migrations, :source_document_type, :string
  end
end
