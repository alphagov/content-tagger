class RootTaxonsForm
  include ActiveModel::Model

  attr_accessor :root_taxons

  def initialize(attributes = {})
    super
    @root_taxons ||= fetch_root_taxons
  end

  def taxons_for_select
    Linkables.new.taxons
  end

  def update
    Services.publishing_api.patch_links(
      GovukTaxonomy::ROOT_CONTENT_ID,
      links: { root_taxons: root_taxons.reject(&:empty?) },
    )
  end

private

  def fetch_root_taxons
    homepage_links = Services.publishing_api.get_links(GovukTaxonomy::ROOT_CONTENT_ID)
    homepage_links.dig('links', 'root_taxons') || []
  end
end
