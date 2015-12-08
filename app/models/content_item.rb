class ContentItem
  attr_reader :content_id, :title, :format, :base_path, :publishing_app

  def initialize(data)
    @content_id = data.fetch('content_id')
    @title = data.fetch('title')
    @format = data.fetch('format')
    @base_path = data.fetch('base_path')
    @publishing_app = data.fetch('publishing_app')
  end

  def self.find!(content_id)
    content_item = Services.publishing_api.get_content(content_id)
    raise ItemNotFound unless content_item
    new(content_item.to_h)
  end

  def link_set
    @link_set ||= LinkSet.find(content_id)
  end

  def app_responsible_for_tagging
    @tagging_apps ||= YAML.load_file("#{Rails.root}/config/tagging-apps.yml")
    @tagging_apps[publishing_app]
  end

  class ItemNotFound < Exception
  end
end
