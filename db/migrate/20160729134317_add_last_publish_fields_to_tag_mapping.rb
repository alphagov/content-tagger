class AddLastPublishFieldsToTagMapping < ActiveRecord::Migration
  def change
    add_column :tag_mappings, :publish_requested_at, :datetime
    add_column :tag_mappings, :publish_completed_at, :datetime
  end
end
