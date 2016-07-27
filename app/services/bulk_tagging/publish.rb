module BulkTagging
  class Publish
    attr_reader :tagging_spreadsheet
    attr_reader :logger
    attr_reader :user

    def initialize(tagging_spreadsheet, user:, logger: Rails.logger)
      @tagging_spreadsheet = tagging_spreadsheet
      @logger = logger
      @user = user
    end

    def run
      errors = []
      begin
        update_publishing_details
        send_links_to_publishing_api
      rescue => e
        errors << e
      end
      errors
    end

  private

    def update_publishing_details
      tagging_spreadsheet.update(
        last_published_by: user.uid, last_published_at: Time.zone.now
      )
    end

    def send_links_to_publishing_api
      link_payloads.each do |base_path, links|
        tagged_log "Patching links on #{base_path}"
        target_content_id = Services.publishing_api.lookup_content_id(base_path: base_path)
        if target_content_id.blank?
          tagged_log "No content ID found for #{base_path}"
          next
        end
        response_code = patch_links(target_content_id, links)
        tagged_log "patch_links response: #{response_code}"
      end
    end

    def patch_links(content_id, links)
      Services.publishing_api.patch_links(content_id, links: links).code
    end

    def tagged_log(message)
      logger.tagged("BULK-TAG") { logger.info message }
    end

    def link_payloads
      tagging_spreadsheet.tag_mappings.each_with_object({}) do |mapping, hash|
        content_base_path = mapping.content_base_path
        link_type = mapping.link_type
        link_content_id = mapping.link_content_id

        hash[content_base_path] = {} unless hash[content_base_path].present?
        hash[content_base_path][link_type] = hash[content_base_path].fetch(link_type, []) << link_content_id
      end
    end
  end
end
