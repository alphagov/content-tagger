class RemoveSourceDescriptionFromTagMigration < ActiveRecord::Migration[4.2]
  def change
    remove_column :tag_migrations, :source_description, :text
  end
end
