class DropTableThemes < ActiveRecord::Migration[5.1]
  def change
    drop_table :themes
  end
end
