require 'gds_api/publishing_api_v2'

module LegacyTaxonomy
  module Client
    class PublishingApi
      class << self
        delegate :put_content,
                 :publish,
                 :patch_links,
                 :get_links,
                 to: :client

        def new_content_id
          SecureRandom.uuid
        end

        def get_linked_items(content_id, link_type)
          linked_items = Services.publishing_api.get_linked_items(content_id, link_type: link_type, fields: %i[base_path content_id])
          linked_items.map { |item| { 'link' => item['base_path'], 'content_id' => item['content_id'] } }
        end

        def content_id_for_base_path(base_path)
          Services.publishing_api.lookup_content_id(base_path: base_path)
        end

        def get_expanded_links(content_id)
          response = Services.publishing_api.get_expanded_links(content_id)
          response.to_h.fetch("expanded_links", {})
        end

        def get_content_groups(content_id)
          response = Services.publishing_api.get_content(content_id)
          response.dig('details', 'groups') || []
        end
      end
    end
  end
end
