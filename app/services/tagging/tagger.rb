module Tagging
  class Tagger
    def self.add_tags(content_id, taxon_ids)
      link_content = Services.publishing_api.get_links(content_id)
      version = link_content["version"]
      taxons = (link_content.dig("links", "taxons") || []) + taxon_ids
      Services.publishing_api.patch_links(content_id, links: { taxons: taxons.uniq }, previous_version: version, bulk_publishing: true)
    rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException
      retries ||= 0
      retry if (retries += 1) < 3
      raise
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("Cannot find content item '#{content_id}' in the publishing api")
    end
  end
end
