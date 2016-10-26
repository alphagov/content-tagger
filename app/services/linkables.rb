class Linkables
  def topics
    @topics ||= for_nested_document_type('topic')
  end

  def taxons(exclude_ids: [])
    @taxons ||=
      begin
        items = for_document_type('taxon')
        if Array(exclude_ids).present?
          items.delete_if { |item| item.last.in? Array(exclude_ids) }
        end
        items
      end
  end

  def organisations
    @organisations ||= for_document_type('organisation')
  end

  def mainstream_browse_pages
    @mainstream_browse_pages ||= for_nested_document_type('mainstream_browse_page')
  end

private

  def for_document_type(document_type)
    items = get_tags_of_type(document_type)
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
    items = get_tags_of_type(document_type)
      .select { |item| item.fetch('internal_name').include?(' / ') }

    organise_items(present_items(items))
  end

  def present_items(items)
    items = items.map do |item|
      title = item.fetch('internal_name')
      title = "#{title} (draft)" if item.fetch("publication_state") == "draft"

      [title, item.fetch('content_id')]
    end

    items.sort_by(&:first)
  end

  def organise_items(items)
    items.group_by { |entry| entry.first.split(' / ').first }
  end

  def get_tags_of_type(document_type)
    items = Services.publishing_api.get_linkables(format: document_type)
    # We only are interested in linkables that have an internal name and not
    # redirects or similar
    items.select { |item| item['internal_name'].present? }
  end
end
