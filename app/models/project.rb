class Project < ActiveRecord::Base
  has_many :content_items, class_name: "ProjectContentItem", dependent: :destroy

  def taxons
    @taxons ||= GovukTaxonomy::Branches.new.taxons_for_branch(taxonomy_branch)
  end

  def taxonomy_branch_title
    @taxonomy_branch_title ||= GovukTaxonomy::Branches.new.branch_name_for_content_id(taxonomy_branch)
  end
end
