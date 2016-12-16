class ContentItemExpandedLinks
  include ActiveModel::Model
  attr_accessor :content_id, :previous_version

  # Temporarily disable ordered_related_items. We can't allow users
  # to edit these in content tagger until the interface is removed from
  # panopticon, because panopticon doesn't read tags from publishing api,
  # and could overwrite them.
  #
  # We'll remove it from panopticon when the javascript is done.
  # https://github.com/alphagov/content-tagger/pull/245
  LIVE_TAG_TYPES = %i(
    taxons
    mainstream_browse_pages
    parent
    topics
    organisations
  ).freeze

  TEST_TAG_TYPES = %i(
    taxons
    ordered_related_items
    mainstream_browse_pages
    parent
    topics
    organisations
  ).freeze

  TAG_TYPES = Rails.env.production? ? LIVE_TAG_TYPES : TEST_TAG_TYPES

  attr_accessor(*TAG_TYPES)

  # Find the links for a content item by its content ID
  def self.find(content_id)
    data = Services.publishing_api.get_expanded_links(content_id).to_h

    links = data.fetch('expanded_links', {})

    new(
      content_id: content_id,
      previous_version: data.fetch('version', 0),
      topics: links.fetch('topics', []),
      organisations: links.fetch('organisations', []),
      mainstream_browse_pages: links.fetch('mainstream_browse_pages', []),
      parent: links.fetch('parent', []),
      taxons: links.fetch('taxons', []),
      ordered_related_items: links.fetch('ordered_related_items', [])
    )
  end
end
