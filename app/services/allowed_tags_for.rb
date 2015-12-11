class AllowedTagsFor
  def self.allowed_tag_types(content_item)
    if content_item.app_responsible_for_tagging == "content-tagger"
      %w(mainstream_browse_pages parent topics organisations)
    else
      []
    end
  end
end
