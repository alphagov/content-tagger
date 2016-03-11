class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_item, :content_id, :previous_version
  attr_accessor :topics, :organisations, :mainstream_browse_pages, :parent, :alpha_taxons

  # Return a new LinkUpdate object with topics, mainstream_browse_pages,
  # organisations and content_item set.
  def self.init_with_content_item(content_item)
    link_set = content_item.link_set

    new(
      content_item: content_item,
      previous_version: link_set.version,
      topics: link_set.links['topics'],
      organisations: link_set.links['organisations'],
      mainstream_browse_pages: link_set.links['mainstream_browse_pages'],
      parent: link_set.links['parent'],
      alpha_taxons: link_set.links['alpha_taxons'],
    )
  end

  def content_id
    @content_id ||= content_item.content_id
  end

  def publish!
    Services.publishing_api.patch_links(
      content_id,
      links: links_payload,
      previous_version: previous_version.to_i,
    )
  end

  def links_payload
    payload = {
      topics: clean_content_ids(topics),
      mainstream_browse_pages: clean_content_ids(mainstream_browse_pages),
      organisations: clean_content_ids(organisations),
      alpha_taxons: clean_content_ids(alpha_taxons),
    }

    # Because 'parent' might be a blacklisted field switched off in the form
    payload.merge!(parent: clean_content_ids(parent)) unless parent.nil?

    payload
  end

private

  def clean_content_ids(select_form_input)
    Array(select_form_input).select(&:present?)
  end
end
