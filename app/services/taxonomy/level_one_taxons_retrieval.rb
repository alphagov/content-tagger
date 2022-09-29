module Taxonomy
  class LevelOneTaxonsRetrieval
    def get(with_drafts: true)
      homepage_links = Services.publishing_api.get_expanded_links(GovukTaxonomy::ROOT_CONTENT_ID, with_drafts:)
      Array.wrap(homepage_links.dig("expanded_links", "level_one_taxons"))
    end
  end
end
