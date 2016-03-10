class TaggingUpdateForm
  include ActiveModel::Model
  attr_accessor :content_item, :content_id, :previous_version
  attr_reader :topics, :organisations, :mainstream_browse_pages, :parent, :alpha_taxons

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
    links_payload = {
      topics: topics,
      mainstream_browse_pages: mainstream_browse_pages,
      organisations: organisations,
      alpha_taxons: alpha_taxons,
    }

    # Because 'parent' might be a blacklisted field switched off in the form
    links_payload.merge!(parent: parent) unless parent.nil?

    Services.publishing_api.patch_links(
      content_id,
      links: links_payload,
      previous_version: previous_version.to_i,
    )
  end

  def topics=(topic_ids)
    @topics = Array(topic_ids).select(&:present?)
  end

  def organisations=(organisation_ids)
    @organisations = Array(organisation_ids).select(&:present?)
  end

  def mainstream_browse_pages=(mainstream_browse_page_ids)
    @mainstream_browse_pages = Array(mainstream_browse_page_ids).select(&:present?)
  end

  def parent=(parent_id)
    @parent = Array(parent_id).select(&:present?)
  end

  def alpha_taxons=(taxon_id)
    @alpha_taxons = Array(taxon_id).select(&:present?)
  end
end
