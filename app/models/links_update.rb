class LinksUpdate
  include ActiveModel::Model
  include ActiveModel::Validations

  validates_with ContentIdValidator
  validates_with LinkTypeValidator
  validates_with TaxonsValidator

  attr_accessor :base_path, :links, :tag_mappings
  attr_reader :content_id

  def content_id
    @content_id ||= Services.publishing_api.lookup_content_id(base_path: base_path)
  end

  def links_to_update
    links
  end

  def link_types
    links.keys
  end

  def taxons
    links.fetch('taxons', [])
  end

  def mark_as_tagged
    tag_mappings.update_all(
      state: 'tagged',
      publish_completed_at: Time.current
    )
  end

  def mark_as_errored
    return if errors.messages.blank?
    message = errors.messages.values.join(' ')
    tag_mappings.update_all(state: :errored, message: message)
  end
end
