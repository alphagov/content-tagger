class RemoveSourceDescriptionFromTagMigration < ActiveRecord::Migration
  def change
    remove_column :tag_migrations, :source_description, :text
  end
end
