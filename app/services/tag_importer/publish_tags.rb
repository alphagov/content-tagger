module TagImporter
  class PublishTags
    attr_reader :tagging_spreadsheet
    attr_reader :tag_mappings
    attr_reader :user

    def initialize(tagging_spreadsheet, user:)
      @tagging_spreadsheet = tagging_spreadsheet
      @tag_mappings = tagging_spreadsheet.tag_mappings
      @user = user
    end

    def run
      ActiveRecord::Base.transaction do
        tagging_spreadsheet.update(last_published_at: Time.zone.now)
        tagging_spreadsheet.update(last_published_by: user.uid)
        tag_mappings.update_all(publish_requested_at: Time.zone.now)

        links_grouped_by_base_path.each do |base_path, links_update|
          PublishLinksWorker.perform_async(base_path, links_update)
        end
      end
    end

  private

    # Take each tag mapping and return a hash in the form:
    # {
    #   "/content/base/path/" => {
    #     "tag_mapping_ids" => [ 1, 2, 3 ]
    #     "taxons"          => [ "taxon1-content-id", "taxon2-content-id ],
    #     "organisations"   => [ "org-content-id" ],
    #   }
    # }
    def links_grouped_by_base_path
      tag_mappings.each_with_object({}) do |mapping, hash|
        content_base_path = mapping.content_base_path
        link_type = mapping.link_type
        link_content_id = mapping.link_content_id

        hash[content_base_path] = {} unless hash[content_base_path].present?
        hash[content_base_path][link_type] = hash[content_base_path].fetch(link_type, []) << link_content_id
        hash[content_base_path]["tag_mapping_ids"] = hash[content_base_path].fetch("tag_mapping_ids", []) << mapping.id
      end
    end
  end
end
