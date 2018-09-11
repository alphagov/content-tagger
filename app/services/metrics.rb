module Metrics
  def self.statsd
    @statsd ||= begin
      statsd_client = Statsd.new
      statsd_client.namespace = "govuk.topic-taxonomy"
      statsd_client
    end
  end
end
