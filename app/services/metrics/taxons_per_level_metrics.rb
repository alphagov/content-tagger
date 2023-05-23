require_relative "../metrics"

module Metrics
  class TaxonsPerLevelMetrics
    def initialize(registry)
      @number_of_taxons_gauge = registry.gauge(:number_of_taxons, docstring: "Number of taxons", labels: %i[level])
    end

    def count_taxons_per_level
      Taxonomy::TaxonomyQuery.new.taxons_per_level.to_enum.with_index(1).each do |taxons, level|
        @number_of_taxons_gauge.set(taxons.length, labels: { level: })
      end
    end
  end
end
