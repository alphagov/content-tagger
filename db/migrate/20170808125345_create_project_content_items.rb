class CreateProjectContentItems < ActiveRecord::Migration[5.0]
  def change
    create_table :project_content_items do |t|
      t.string :url
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
