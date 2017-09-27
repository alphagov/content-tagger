class RemoveBulkTaggerFromProject < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects, :bulk_tagging_enabled
  end
end
