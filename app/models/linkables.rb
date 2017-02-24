# Used by Tagging & Bulk Tagging to populate the available tags.
class Linkables
  def topics
    @topics ||= for_nested_document_type('topic')
  end

  def taxons(exclude_ids: [])
    @taxons ||= for_document_type('taxon').tap do |items|
      if Array(exclude_ids).present?
        items.delete_if { |item| item.second.in? Array(exclude_ids) }
      end
    end
  end

  def organisations
    @organisations ||= for_document_type('organisation')
  end

  def needs
    @needs ||= for_document_type('need', include_draft: false)
  end

  def mainstream_browse_pages
    @mainstream_browse_pages ||= for_nested_document_type('mainstream_browse_page')
  end

  def get_tags_of_type(document_type)
    items = Services
      .publishing_api
      .get_content_items(
        document_type: document_type,
        q: '',
        page: 1,
        per_page: 10_000,
        states: %w(live published draft),
        fields: [:content_id, :publication_state, :title, :base_path, :details],
    )

    items['results']
      .map { |result| Linkable.new(result.merge('document_type' => document_type)) }
      .select(&:valid_internal_name?)
  end

private

  def for_document_type(document_type, include_draft: true)
    items = get_tags_of_type(document_type)
    items = items.reject(&:draft?) unless include_draft
    present_items(items)
  end

  def for_nested_document_type(document_type)
    # In Topics and Browse pages, the "internal name" is generated in the
    # form: "Parent title / Child title". Because currently we only show
    # documents on child-topic pages (like /topic/animal-welfare/pets), we
    # only allow tagging to those tags in this application. That's why we
    # filter out the top-level (which don't have the slash) topics/browse
    # pages here. This of course is temporary, until we've introduced a
    # global taxonomy that will allow editors to tag to any level.
    items = get_tags_of_type(document_type).select do |item|
      item.internal_name.include?(' / ')
    end

    organise_items(present_items(items))
  end

  def present_items(items)
    items = items.map do |item|
      title = item.internal_name
      title = "#{title} (draft)" if item.draft?

      [title, item.content_id]
    end

    items.sort_by(&:first)
  end

  def organise_items(items)
    items.group_by { |entry| entry.first.split(' / ').first }
  end
end
