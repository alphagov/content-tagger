class CreateTagMigrations < ActiveRecord::Migration[4.2]
  def change
    create_table :tag_migrations do |t|
      t.timestamps null: false
    end
  end
end
