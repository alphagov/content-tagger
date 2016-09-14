class MakeTagMappingPolymorphic < ActiveRecord::Migration
  def change
    rename_column :tag_mappings, :tagging_spreadsheet_id, :tagging_source_id
    add_column :tag_mappings, :tagging_source_type, :string

    execute "UPDATE tag_mappings SET tagging_source_type = 'TaggingSpreadsheet'"
  end
end
