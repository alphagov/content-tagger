class AddValueToTaxonomyHealthWarning < ActiveRecord::Migration[5.2]
  def change
    add_column :taxonomy_health_warnings, :value, :integer
  end
end
