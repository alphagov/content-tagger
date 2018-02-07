class AddLastPublishFieldsToTagMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :tag_mappings, :publish_requested_at, :datetime
    add_column :tag_mappings, :publish_completed_at, :datetime
  end
end
