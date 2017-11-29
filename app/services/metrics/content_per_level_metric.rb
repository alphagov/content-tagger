module Metrics
  class ContentPerLevelMetric
    def self.count_content_per_level
      counts_by_level = Taxonomy::TaxonomyQuery.new.taxons_per_level.map do |taxons|
        taxon_contend_ids = taxons.map { |h| h['content_id'] }
        Taxonomy::TaxonomyQuery.new.content_tagged_to_taxons(taxon_contend_ids).size
      end
      counts_by_level.each_with_index do |count, level|
        Services.statsd.gauge("content_tagged.level_#{level + 1}", count)
      end
    end
  end
end
