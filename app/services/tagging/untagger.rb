module Tagging
  class Untagger
    def self.call(content_id, taxon_content_ids)
      new.untag(content_id, taxon_content_ids)
    end

    def untag(content_id, taxon_content_ids)
      response = Services.publishing_api.get_links(content_id)
      existing_taxons_ids = response.dig('links', 'taxons')
      version = response['version']

      Services.publishing_api.patch_links(content_id,
                                          previous_version: version,
                                          links: { taxons: (existing_taxons_ids - taxon_content_ids) })
    rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException
      retries ||= 0
      retry if (retries += 1) < 3
      raise
    end
  end
end
