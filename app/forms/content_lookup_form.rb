class ContentLookupForm
  attr_accessor :base_path
  include ActiveModel::Model

  validates_presence_of :base_path
  validate :base_path_should_be_a_content_item

  delegate :content_id, to: :content_item

private

  def content_item
    @content_item ||= Services.content_store.content_item(base_path)
  end

  def base_path_should_be_a_content_item
    return if errors.any?
    strip_host && content_item_should_have_been_found!
  end

  def content_item_should_have_been_found!
    return true if content_item
    errors[:base_path] << "No page found with this path"
    false
  end

  def strip_host
    self.base_path = URI.parse(base_path).path
  rescue URI::InvalidURIError
    errors[:base_path] << "This is not a valid URL or path"
    false
  end
end
