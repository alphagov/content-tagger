class Project < ActiveRecord::Base
  has_many :content_items, class_name: 'ProjectContentItem'

  def taxons
    @_taxons ||= GovukTaxonomy::Branches.new.taxons_for_branch(taxonomy_branch)
  end

  def taxonomy_branch_title
    @_title ||= GovukTaxonomy::Branches.new.branch_name_for_content_id(taxonomy_branch)
  end
end
