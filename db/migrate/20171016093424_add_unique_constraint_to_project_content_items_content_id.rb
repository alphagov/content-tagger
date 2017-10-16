class AddUniqueConstraintToProjectContentItemsContentId < ActiveRecord::Migration[5.0]
  def change
    # Remove duplicate ProjectContentItem records. These were introduced when
    # another project was created with content items that were already tagged
    # in a previous import/project.

    execute <<-SQL
      DELETE FROM project_content_items
      WHERE id IN (3896, 3883, 3825, 3773, 3752, 3880, 3909, 3987, 3810, 3927, 1875)
    SQL

    add_index :project_content_items, :content_id, unique: true
  end
end
