class AllowedTagsFor
  MIGRATED_APPS = %(smartanswers a-migrated-app)

  def self.allowed_tag_types(content_item)
    if content_item.publishing_app.in?(MIGRATED_APPS)
      %w(topics organisations mainstream_browse_pages)
    else
      []
    end
  end
end
