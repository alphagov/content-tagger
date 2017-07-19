module LegacyTaxonomy
  class Statistics
    attr_reader :root_taxon

    def initialize(root_taxon)
      @root_taxon = root_taxon
    end

    def to_a
      flatten_taxons(root_taxon)
    end

    def flatten_taxons(taxon)
      taxons = []
      taxons << taxon.to_stats_hash
      taxon.child_taxons.each do |child_taxon|
        taxons += flatten_taxons(child_taxon)
      end
      taxons
    end
  end
end
