module LegacyTaxonomy
  class LegacyTaxonomiesIndex
    def initialize(taxonomies)
      @cache = {}
      fill_cache(taxonomies)
    end

    def tagged_pages(legacy_taxon_content_id)
      @cache[legacy_taxon_content_id].try(:tagged_pages) || []
    end

  private

    def fill_cache(taxonomies)
      taxonomies.each do |taxonomy|
        @cache[taxonomy.legacy_content_id] = taxonomy
        fill_cache(taxonomy.child_taxons)
      end
    end
  end
end
