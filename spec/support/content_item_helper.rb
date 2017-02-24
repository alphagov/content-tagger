module ContentItemHelper
  def content_item_with_details(title, other_fields: {})
    other_fields_with_details = other_fields.merge(
      details: {
        internal_name: "internal name for #{title}",
        notes_for_editors: "Editor notes for #{title}"
      }
    )
    basic_content_item(title, other_fields: other_fields_with_details)
  end

  def basic_content_item(title, other_fields: {})
    ActiveSupport::HashWithIndifferentAccess.new(
      content_id: title.parameterize,
      title: title,
      base_path: title.parameterize.prepend('/path/'),
      document_type: "guidance",
      publication_state: 'live',
    ).merge(other_fields)
  end
end
