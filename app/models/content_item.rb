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
    new Services.publishing_api.get_content(content_id).to_h
  end
end
