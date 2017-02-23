require 'gds_api/publishing_api_v2'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,

      # TODO: revisit this when get_linkables reliably responds in under 4 seconds
      timeout: 15.seconds,

      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
