class AddTaxonomyBranchToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :taxonomy_branch, :uuid
  end
end
