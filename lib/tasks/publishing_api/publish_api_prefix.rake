require 'logger'
require 'gds_api/publishing_api'
require 'gds_api/publishing_api/special_route_publisher'

namespace :publishing_api do
  desc "Publish /api route to publishing_api"
  task publish_api_prefix: :environment do
    puts "Content Tagger is claiming path /api"
    endpoint = Services.publishing_api.options[:endpoint_url]
    Services.publishing_api.put_json("#{endpoint}/paths/api", publishing_app: "content-tagger", override_existing: true)

    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )

    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new(STDOUT),
      publishing_api: publishing_api
    )

    puts "Publishing /api..."
    special_route_publisher.publish(
      title: 'Public content API',
      description: '/api was used by Content API which has been retired. It is used by other applications such as search, whitehall, content-store and calendars.',
      content_id: "363a1f3a-5e80-4ff7-8f6f-be1bec62821f",
      base_path: '/api',
      type: 'prefix',
      publishing_app: 'content-tagger',
      rendering_app: 'publicapi'
    )
  end
end
