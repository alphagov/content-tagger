class MakeTagMappingPolymorphic < ActiveRecord::Migration
  def change
    rename_column :tag_mappings, :tagging_spreadsheet_id, :tagging_source_id
    add_column :tag_mappings, :tagging_source_type, :string

    TagMapping.transaction do
      TagMapping.all.each do |tag_mapping|
        tag_mapping.update!(taggable_type: 'TaggingSpreadsheet')
      end
    end
  end
end
