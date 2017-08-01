class CreateThemes < ActiveRecord::Migration[5.0]
  def change
    create_table :themes, id: false do |t|
      t.string :path_prefix, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :themes, :path_prefix
  end
end
