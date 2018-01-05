namespace :metrics do
  namespace :taxonomy do
    desc "Count all content tagged to each level in the taxonomy"
    task count_content_per_level: :environment do
      Statsd.logger = Logger.new(STDOUT)

      m = Metrics::ContentDistributionMetrics.new
      m.count_content_per_level
      m.average_tagging_depth
    end

    desc "Record metrics on content coverage for the Topic Taxonomy"
    task record_content_coverage_metrics: :environment do
      Statsd.logger = Logger.new(STDOUT)

      Metrics::ContentCoverageMetrics.new.record_all
    end
  end
end
