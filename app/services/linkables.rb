# Used by Tagging & Bulk Tagging to populate the available tags.
class Linkables
  def topics
    @topics ||= for_nested_document_type("topic")
  end

  def taxons(exclude_ids: [], include_draft: true)
    @taxons ||= for_document_type("taxon", include_draft: include_draft).tap do |items|
      if Array(exclude_ids).present?
        items.delete_if { |item| item.second.in? Array(exclude_ids) }
      end
    end
  end

  def taxons_including_root(exclude_ids: [])
    [[GovukTaxonomy::TITLE, GovukTaxonomy::ROOT_CONTENT_ID]] + taxons(exclude_ids: exclude_ids)
  end

  def organisations
    @organisations ||= for_document_type("organisation")
  end

  def needs
    @needs ||= for_document_type("need", include_draft: false)
  end

  def mainstream_browse_pages
    @mainstream_browse_pages ||= for_nested_document_type("mainstream_browse_page")
  end

private

  def for_document_type(document_type, include_draft: true)
    items = get_tags_of_type(document_type)
    unless include_draft
      items = items.reject { |x| x["publication_state"] == "draft" }
    end
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
      .select { |item| item.fetch("internal_name").include?(" / ") }

    organise_items(present_items(items))
  end

  def present_items(items)
    items = items.map do |item|
      title = item.fetch("internal_name")
      title = "#{title} (draft)" if item.fetch("publication_state") == "draft"

      [title, item.fetch("content_id")]
    end

    items.sort_by(&:first)
  end

  def organise_items(items)
    items.group_by { |entry| entry.first.split(" / ").first }
  end

  def get_tags_of_type(document_type)
    items = Services.statsd.time "linkables.#{document_type}" do
      Services.publishing_api.get_linkables(document_type: document_type)
    end

    # We only are interested in linkables that have an internal name and not
    # redirects or similar
    items.select { |item| item["internal_name"].present? }
  end
end
