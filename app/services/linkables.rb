# Used by Tagging & Bulk Tagging to populate the available tags.
class Linkables
  CACHE_OPTIONS = { expires_in: 15.minutes, race_condition_ttl: 30.seconds }.freeze

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

    items = filter_browse_topics(items)

    organise_items(present_items(items))
  end

  # While we're migrating the Browse pages to topics we will briefly have a combination of the
  # two in our model. We need to filter out the pages we brought across from the results.
  def filter_browse_topics(all_topics)
    return all_topics if all_topics.empty? || all_topics.first.fetch("base_path").exclude?("/topic/")

    # Get topics that are not mainstream browse copies
    valid_topics ||= Rails.cache.fetch("valid_topics", CACHE_OPTIONS) do
      Services.publishing_api.get_content_items(document_type: "topic", per_page: 10_000, fields: %w[content_id details])["results"].select do |item|
        item.dig("details", "mainstream_browse_origin").nil?
      end
    end

    # Filter the invalid topics out of the items collection
    all_topics.select { |item| valid_topics.any? { |topic| topic.fetch("content_id") == item.fetch("content_id") } }
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
