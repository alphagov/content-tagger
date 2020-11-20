require "gds_api/publishing_api"
require "gds_api/search"
require "gds_api/content_store"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end

  def self.publishing_api_with_long_timeout
    @publishing_api_with_long_timeout ||= begin
      publishing_api.dup.tap do |client|
        client.options[:timeout] = 15
      end
    end
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.current.find("draft-content-store"))
  end

  def self.live_content_store
    @live_content_store ||= GdsApi::ContentStore.new(Plek.current.find("content-store"))
  end

  def self.statsd
    @statsd ||= begin
      statsd_client = Statsd.new
      statsd_client.namespace = "govuk.app.content-tagger"
      statsd_client
    end
  end

  def self.search_api
    @search_api ||= GdsApi::Search.new(
      Plek.new.find("search"),
    )
  end
end
