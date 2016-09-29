class PublishLinks
  attr_reader :links_update

  def self.call(links_update:)
    new(links_update: links_update).publish
  end

  def initialize(links_update:)
    @links_update = links_update
  end

  def publish
    Services.publishing_api.patch_links(
      links_update.content_id,
      links: updated_links,
      previous_version: previous_version
    )
  end

private

  def updated_links
    links_update.links_to_update.merge(existing_links) do |_, new_links, old_links|
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
      Services.publishing_api.get_links(links_update.content_id)
  end
end
