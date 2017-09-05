class AddBulkTaggingEnabledFlagToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :bulk_tagging_enabled, :boolean, default: false
  end
end
