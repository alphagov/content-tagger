module LegacyTaxonomy
  module Client
    class PublishingApi
      class << self
        def new_content_id
          SecureRandom.uuid
        end

        def content_id_for_base_path(base_path)
          Services.publishing_api.lookup_content_id(base_path: base_path)
        end

        def get_expanded_links(content_id)
          response = client.get_expanded_links(content_id)
          response.to_h.fetch("expanded_links", {})
        end

        def get_content_groups(content_id)
          response = client.get_content(content_id)
          response.dig('details', 'groups') || []
        end

        def client
          @publishing_api ||= GdsApi::PublishingApiV2.new(
            Plek.new.find('publishing-api'),
            disable_cache: true,
            bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
            timeout: 120
          )
        end
      end
    end
  end
end
