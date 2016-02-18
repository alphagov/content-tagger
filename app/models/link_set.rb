class LinkSet
  attr_reader :links, :version

  def self.find(content_id)
    link_set = Services.publishing_api.get_links(content_id)
    new(link_set.to_h)
  end

  def initialize(data)
    @links = data['links'] || {}
    # TODO: Remove check for `version` once the rename of the
    # field has been deployed.
    @version = data['lock_version'] || data['version'] || 0
  end
end
