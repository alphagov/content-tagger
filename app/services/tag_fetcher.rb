# TagFetcher
#
# Return a list of tags for a select box. Gets data from the publishing-api.
class TagFetcher
  def tags_of_type(content_format)
    content_items = fetch_items_for_format(content_format)
    present_items_for_select(content_items)
  end

private

  def fetch_items_for_format(content_format)
    Services.publishing_api.get_content_items(
      content_format: content_format,
      fields: %i(title content_id details)
    )
  end

  def present_items_for_select(items)
    items.map { |tag| TagItem.new(tag).to_select }.sort_by(&:first)
  end

  class TagItem
    attr_accessor :content_id, :title, :publication_state, :details
    include ActiveModel::Model

    def to_select
      [tag_name_with_publication_state, content_id]
    end

  private

    def tag_name_with_publication_state
      name = details.to_h.fetch('internal_name', title)
      if publication_state == 'draft'
        "#{name} (#{publication_state})"
      else
        name
      end
    end
  end
end
