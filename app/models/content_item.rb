class ContentItem

  attr_reader :content_id, :title, :base_path, :publishing_app, :document_type

  def initialize(data)
    @content_id = data.fetch('content_id')
    @title = data.fetch('title')
    @base_path = data.fetch('base_path')
    @publishing_app = data.fetch('publishing_app', nil)
    @document_type = data.fetch('document_type')
  end

  def self.find!(content_id)
    content_item = Services.publishing_api.get_content(content_id)
    raise ItemNotFoundError if content_item['document_type'].in?(%w(redirect gone))
    new(content_item.to_h)
  rescue GdsApi::HTTPNotFound
    raise ItemNotFoundError
  end

  def link_set
    @link_set ||= ContentItemExpandedLinks.find(content_id)
  end

  def blacklisted_tag_types
    blacklist = YAML.load_file("#{Rails.root}/config/blacklisted-tag-types.yml")
    Array(blacklist[publishing_app]).map(&:to_sym) + additional_temporary_blacklist
  end

  def allowed_tag_types
    ContentItemExpandedLinks::TAG_TYPES - blacklisted_tag_types
  end

  class ItemNotFoundError < StandardError
  end

private

  def additional_temporary_blacklist
    publishing_app == 'specialist-publisher' && document_type == 'finder' ? [:topics] : []
  end
end
