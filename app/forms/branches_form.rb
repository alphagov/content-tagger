class BranchesForm
  include ActiveModel::Model

  attr_accessor :branches

  def initialize(attributes = {})
    super
    @branches ||= fetch_branches
  end

  def taxons_for_select
    Linkables.new.taxons
  end

  def update
    Services.publishing_api.patch_links(
      GovukTaxonomy::ROOT_CONTENT_ID,
      links: { root_taxons: branches.reject(&:empty?) },
    )
  end

private

  def fetch_branches
    homepage_links = Services.publishing_api.get_links(GovukTaxonomy::ROOT_CONTENT_ID)
    homepage_links.dig('links', 'root_taxons') || []
  end
end
