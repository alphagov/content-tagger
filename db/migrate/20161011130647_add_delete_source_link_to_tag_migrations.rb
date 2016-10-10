class AddDeleteSourceLinkToTagMigrations < ActiveRecord::Migration
  def change
    add_column(
      :tag_migrations,
      :delete_source_link,
      :boolean,
      default: false
    )
  end
end
