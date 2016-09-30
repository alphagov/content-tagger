module ContentItemHelper
  def basic_content_item(title, other_fields: {})
    ActiveSupport::HashWithIndifferentAccess.new(
      content_id: title.parameterize,
      title: title,
      base_path: title.parameterize.prepend('/path/'),
      document_type: "guidance",
    ).merge(other_fields)
  end

  def build_linkable(hash)
    default = {
      content_id: SecureRandom.uuid,
      title: SecureRandom.hex,
      internal_name: SecureRandom.hex,
      base_path: "/#{SecureRandom.hex}",
      document_type: SecureRandom.hex,
      publication_state: %w(live draft).sample,
    }

    default.stringify_keys.merge(hash.stringify_keys)
  end
end
