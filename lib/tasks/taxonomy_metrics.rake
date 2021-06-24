namespace :metrics do
  namespace :taxonomy do
    desc "Count all content tagged to each level in the taxonomy"
    task count_content_per_level: :environment do
      Statsd.logger = Logger.new($stdout)

      m = Metrics::ContentDistributionMetrics.new
      m.count_content_per_level
      m.average_tagging_depth
    end

    desc "Record metrics on content coverage for the Topic Taxonomy"
    task record_content_coverage_metrics: :environment do
      Statsd.logger = Logger.new($stdout)

      Metrics::ContentCoverageMetrics.new.record_all
    end

    desc "Record number of taxons per level in the Topic Taxonomy"
    task record_taxons_per_level_metrics: :environment do
      Statsd.logger = Logger.new($stdout)

      Metrics::TaxonsPerLevelMetrics.new.count_taxons_per_level
    end

    desc "Record number of superfluous taggings"
    task record_number_of_superfluous_taggings_metrics: :environment do
      Statsd.logger = Logger.new($stdout)

      Metrics::SuperfluousTaggingsMetrics.new.count
    end

    desc "Record all metrics about the Topic Taxonomy"
    task record_all: %i[
      count_content_per_level
      record_taxons_per_level_metrics
      record_content_coverage_metrics
    ]
  end
end
