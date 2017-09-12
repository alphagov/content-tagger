require 'gds_api/publishing_api_v2'
require 'gds_api/rummager'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end

  def self.link_changes_api
    @link_changes_api ||= Analytics::LinkChangeApi.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end

  def self.statsd
    @statsd_client ||= begin
      statsd_client = Statsd.new
      statsd_client.namespace = "govuk.app.content-tagger"
      statsd_client
    end
  end

  def self.rummager
    @search ||= GdsApi::Rummager.new(
      Plek.new.find('rummager'),
    )
  end
end
