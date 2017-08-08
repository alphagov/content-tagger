class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name

      t.timestamps
    end

    add_reference :project_content_items, :project, foreign_key: true
  end
end
