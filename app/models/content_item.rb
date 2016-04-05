class ContentItem
  TAG_TYPES = %w(mainstream_browse_pages parent topics organisations alpha_taxons)

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
    raise ItemNotFoundError unless content_item
    new(content_item.to_h)
  end

  def link_set
    @link_set ||= LinkSet.find(content_id)
  end

  def tagging_allowed?
    app_responsible_for_tagging == "content-tagger"
  end

  def app_responsible_for_tagging
    return if format.in?(%w(redirect gone))

    @tagging_apps ||= YAML.load_file("#{Rails.root}/config/blacklisted-apps.yml")
    @tagging_apps.include?(publishing_app) ? publishing_app : "content-tagger"
  end

  def external_tagging_url
    if app_responsible_for_tagging == 'whitehall'
      Plek.new.find('whitehall-admin')
    else
      Plek.new.find(app_responsible_for_tagging)
    end
  end

  def blacklisted_tag_types
    blacklist = YAML.load_file("#{Rails.root}/config/blacklisted-tag-types.yml")
    Array blacklist[publishing_app]
  end

  class ItemNotFoundError < StandardError
  end
end
