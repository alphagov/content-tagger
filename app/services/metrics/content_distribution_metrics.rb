require_relative "../metrics"

module Metrics
  class ContentDistributionMetrics
    def initialize(registry)
      @content_distribution_gauge = registry.gauge(:content_distribution, docstring: "Content distribution metrics", labels: %i[level])
      @average_tagging_depth_gauge = registry.gauge(:average_tagging_depth, docstring: "Average tagging depth")
    end

    def count_content_per_level
      counts_by_level.to_enum.with_index(1).each do |count, level|
        @content_distribution_gauge.set(count, labels: { level: })
      end
    end

    def average_tagging_depth
      sum = counts_by_level.sum.to_f
      avg_depth = counts_by_level.to_enum.with_index(1).reduce(0.0) do |result, (count, level)|
        result + (count.to_f / sum) * level
      end
      @average_tagging_depth_gauge.set(avg_depth)
    end

  private

    def counts_by_level
      @counts_by_level ||= Taxonomy::TaxonomyQuery.new.taxons_per_level.map do |taxons|
        taxon_contend_ids = taxons.map { |h| h["content_id"] }
        Taxonomy::TaxonomyQuery.new.content_tagged_to_taxons(taxon_contend_ids).size
      end
    end
  end
end
