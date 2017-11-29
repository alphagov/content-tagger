namespace :metrics do
  namespace :taxonomy do
    desc "Count all content tagged to each level in the taxonomy"
    task count_content_per_level: :environment do
      m = Metrics::ContentDistributionMetrics.new
      m.count_content_per_level
      m.average_tagging_depth
    end

    task record_content_coverage_metrics: :environment do
      Metrics::ContentCoverageMetrics.new.record_all
    end
  end
end
