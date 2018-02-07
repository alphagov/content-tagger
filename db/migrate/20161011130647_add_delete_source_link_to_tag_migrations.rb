class AddDeleteSourceLinkToTagMigrations < ActiveRecord::Migration[4.2]
  def change
    add_column(
      :tag_migrations,
      :delete_source_link,
      :boolean,
      default: false
    )
  end
end
