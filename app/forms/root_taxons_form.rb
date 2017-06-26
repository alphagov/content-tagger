class RootTaxonsForm
  include ActiveModel::Model

  HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

  attr_accessor :root_taxons

  def initialize(attributes = {})
    super
    @root_taxons ||= fetch_root_taxons
  end

  def taxons_for_select
    Linkables.new.taxons
  end

  def update
    Services.publishing_api.patch_links(HOMEPAGE_CONTENT_ID,
                                        links: { root_taxons: root_taxons.reject(&:empty?) })
  end

private

  def fetch_root_taxons
    homepage_links = Services.publishing_api.get_links(HOMEPAGE_CONTENT_ID)
    homepage_links.dig('links', 'root_taxons') || []
  end
end
