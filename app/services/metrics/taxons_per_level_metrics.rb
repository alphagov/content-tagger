require_relative "../metrics"

module Metrics
  class TaxonsPerLevelMetrics
    def count_taxons_per_level
      Taxonomy::TaxonomyQuery.new.taxons_per_level.to_enum.with_index(1).each do |taxons, level|
        gauge("level_#{level}.number_of_taxons", taxons.length)
      end
    end

  private

    def gauge(stat, value)
      Metrics.statsd.gauge(stat, value)
    end
  end
end
