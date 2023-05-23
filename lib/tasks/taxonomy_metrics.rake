require "prometheus/client"
require "prometheus/client/push"

namespace :metrics do
  namespace :taxonomy do
    desc "Count all content tagged to each level in the taxonomy"
    task count_content_per_level: :environment do
      registry = Prometheus::Client.registry

      m = Metrics::ContentDistributionMetrics.new(registry)
      m.count_content_per_level
      m.average_tagging_depth

      Prometheus::Client::Push.new(
        job: "content_tagger_count_content_per_level",
        gateway: PROMETHEUS_PUSHGATEWAY_URL,
      ).add(registry)
    end

    desc "Record number of taxons per level in the Topic Taxonomy"
    task record_taxons_per_level_metrics: :environment do
      registry = Prometheus::Client.registry

      Metrics::TaxonsPerLevelMetrics.new(registry).count_taxons_per_level
      Prometheus::Client::Push.new(
        job: "content_tagger_taxons_per_level",
        gateway: PROMETHEUS_PUSHGATEWAY_URL,
      ).add(registry)
    end

    desc "Record metrics on content coverage for the Topic Taxonomy"
    task record_content_coverage_metrics: :environment do
      registry = Prometheus::Client.registry

      Metrics::ContentCoverageMetrics.new(registry).record_all
      Prometheus::Client::Push.new(
        job: "content_tagger_content_coverage",
        gateway: PROMETHEUS_PUSHGATEWAY_URL,
      ).add(registry)
    end

    desc "Record number of superfluous taggings"
    task record_number_of_superfluous_taggings_metrics: :environment do
      Metrics::SuperfluousTaggingsMetrics.new.count
    end

    desc "Record all metrics about the Topic Taxonomy"
    task record_all: :environment do
      registry = Prometheus::Client.registry

      m = Metrics::ContentDistributionMetrics.new(registry)
      m.count_content_per_level
      m.average_tagging_depth

      Metrics::TaxonsPerLevelMetrics.new(registry).count_taxons_per_level

      Metrics::ContentCoverageMetrics.new(registry).record_all

      Prometheus::Client::Push.new(
        job: "content_tagger_taxonomy_metrics",
        gateway: PROMETHEUS_PUSHGATEWAY_URL,
      ).add(registry)
    end
  end
end
