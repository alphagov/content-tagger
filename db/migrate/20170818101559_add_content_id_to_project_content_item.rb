class AddContentIdToProjectContentItem < ActiveRecord::Migration[5.0]
  def change
    add_column :project_content_items, :content_id, :uuid
  end
end
