class AddNeedHelpCommentToProjectContentItem < ActiveRecord::Migration[5.0]
  def change
    add_column :project_content_items, :need_help_comment, :text
  end
end
