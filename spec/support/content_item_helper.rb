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

  def publishing_api_has_linked_content_items(content_id, link_type, response_body)
    publishing_api_endpoint = "#{Plek.current.find('publishing-api')}/v2/linked/#{content_id}?"
    request_parmeters = {
      "fields" => %w(base_path content_id document_type title),
      "link_type" => link_type,
    }.to_query

    stub_request(:get, "#{publishing_api_endpoint}#{request_parmeters}")
      .and_return(body: response_body.to_json, status: 200)
  end
end
