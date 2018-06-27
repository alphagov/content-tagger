require_relative '../metrics'

module Metrics
  class SuperfluousTagginsMetrics
    def count
      sum = Tagging::CommonAncestorFinder.call.sum do |ca_result|
        ca_result[:common_ancestors].count
      end
      gauge("superfluous_tagging_count", sum)
    end

  private

    def gauge(stat, value)
      Metrics.statsd.gauge(stat, value)
    end
  end
end
