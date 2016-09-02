module ContentItemHelper
  def basic_content_item(title, other_fields: {})
    ActiveSupport::HashWithIndifferentAccess.new(
      content_id: title.parameterize,
      title: title,
      base_path: title.parameterize.prepend('/path/'),
      document_type: "guidance",
    ).merge(other_fields)
  end
end
