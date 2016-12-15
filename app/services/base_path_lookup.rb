class BasePathLookup
  RelatedContentItem = Struct.new("RelatedContentItem", :content_id, :base_path)

  def self.find_by_base_path(base_path)
    self.find_by_base_paths([base_path]).first
  end

  def self.find_by_base_paths(base_paths_or_urls)
    return [] if base_paths_or_urls.empty?

    base_paths = base_paths_or_urls.map { |ri| URI.parse(ri).path }
    content_id_by_path = Services.publishing_api.lookup_content_ids(
      base_paths: base_paths
    )

    base_paths.map { |path| RelatedContentItem.new(content_id_by_path[path], path) }
  end
end
