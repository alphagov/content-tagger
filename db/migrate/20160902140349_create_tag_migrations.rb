class CreateTagMigrations < ActiveRecord::Migration
  def change
    create_table :tag_migrations do |t|
      t.timestamps null: false
    end
  end
end
