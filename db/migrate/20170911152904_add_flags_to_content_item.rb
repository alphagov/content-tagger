class AddFlagsToContentItem < ActiveRecord::Migration[5.0]
  def change
    add_column :project_content_items, :flag, :integer
    add_column :project_content_items, :suggested_tags, :string

    add_index :project_content_items, :flag
  end
end
