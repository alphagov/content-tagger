namespace :metrics do
  namespace :taxonomy do
    desc "Count all content tagged to each level in the taxonomy"
    task count_content_per_level: :environment do
      Metrics::ContentPerLevelMetric.count_content_per_level
    end
  end
end
