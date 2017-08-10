class AddDoneColumnToProjectContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :project_content_items, :done, :boolean, default: false
  end
end
