module Metrics
  class ContentDistributionMetrics
    def count_content_per_level
      counts_by_level.each_with_index do |count, level|
        Metrics.statsd.gauge("level_#{level + 1}.content_tagged", count)
        Metrics.statsd.gauge("level_#{level + 1}.level", level)
      end
    end

    def average_tagging_depth
      sum = counts_by_level.sum.to_f
      avg_depth = counts_by_level.to_enum.with_index(1).reduce(0.0) do |result, (count, level)|
        result + (count.to_f / sum) * level
      end
      Metrics.statsd.gauge("average_tagging_depth", avg_depth)
    end

  private

    def counts_by_level
      @counts_by_level ||= Taxonomy::TaxonomyQuery.new.taxons_per_level.map do |taxons|
        taxon_contend_ids = taxons.map { |h| h['content_id'] }
        Taxonomy::TaxonomyQuery.new.content_tagged_to_taxons(taxon_contend_ids).size
      end
    end
  end
end
