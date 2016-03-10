# TagFetcher
#
# Return a list of tags for a select box. Gets data from the publishing-api.
class TagFetcher
  def tags_of_type(content_format)
    content_items = fetch_items_for_format(content_format)
    present_items_for_select(content_items)
  end

private

  def fetch_items_for_format(document_type)
    Services.publishing_api.get_linkables(document_type: document_type)
  end

  def present_items_for_select(items)
    items.map do |tag|
      [tag_name_with_publication_state(tag), tag.fetch('content_id')]
    end
  end

  def tag_name_with_publication_state(item)
    name = item['internal_name'] || item.fetch('title')
    publication_state = item.fetch('publication_state')

    if publication_state == 'draft'
      "#{name} (#{publication_state})"
    else
      name
    end
  end
end
