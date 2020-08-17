module Tagging
  class Tagger
    def self.add_tags(content_id, link_ids, link_type)
      link_content = Services.publishing_api.get_links(content_id)
      version = link_content["version"]
      current_links = Array(link_content.dig("links", link_type.to_s))
      links = (current_links + link_ids).uniq
      Services.publishing_api.patch_links(content_id, links: { "#{link_type}": links }, previous_version: version, bulk_publishing: true)
    rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException
      retries ||= 0
      retry if (retries += 1) < 3
      raise
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("Cannot find content item '#{content_id}' in the publishing api")
    end
  end
end
