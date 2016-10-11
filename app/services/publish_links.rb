class PublishLinks
  attr_reader :tag_mapping

  def self.call(tag_mapping:)
    new(tag_mapping: tag_mapping).publish
  end

  def initialize(tag_mapping:)
    @tag_mapping = tag_mapping
  end

  def publish
    Services.publishing_api.patch_links(
      tag_mapping.content_id,
      links: updated_links,
      previous_version: previous_version
    )
  end

private

  def links_to_update
    {
      tag_mapping.link_type => [tag_mapping.link_content_id]
    }
  end

  def updated_links
    links_to_update.merge(existing_links) do |_, new_links, old_links|
      (old_links || []).concat(new_links).uniq
    end
  end

  def existing_links
    links_response['links']
  end

  def previous_version
    links_response['version']
  end

  def links_response
    @links_response ||=
      Services.publishing_api.get_links(tag_mapping.content_id)
  end
end
