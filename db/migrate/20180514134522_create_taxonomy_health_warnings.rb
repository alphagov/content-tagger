class CreateTaxonomyHealthWarnings < ActiveRecord::Migration[5.2]
  def change
    create_table :taxonomy_health_warnings do |t|
      t.uuid :content_id
      t.string :title
      t.string :internal_name
      t.string :path
      t.string :metric
      t.text :message

      t.timestamps
    end
  end
end
