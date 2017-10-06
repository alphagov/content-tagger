class TaggedContentExporter
  TRANSPORT_TAXON_ID = "a4038b29-b332-4f13-98b1-1c9709e216bc".freeze
  WEBSITE_ROOT = Plek.new.website_root

  def self.call
    new.content_items_with_taxons.compact
  end

  def initialize
    @content_items = ProjectContentItem
      .for_taxonomy_branch(TRANSPORT_TAXON_ID)
      .done
  end

  def content_items_with_taxons
    @content_items.map do |content_item|
      {
        content_id: content_item.content_id,
        url: content_item.url.gsub(WEBSITE_ROOT, ""),
        taxons: taxons_for(content_item).compact
      }
    end
  end

private

  def taxons_for(content_item)
    links = Services.publishing_api.get_links(content_item.content_id).to_h
    (links.dig("links", "taxons") || []).map do |taxon_id|
      {
        content_id: taxon_id
      }.merge(metadata_for_taxon(taxon_id, content_item.content_id))
    end
  end

  def metadata_for_taxon(taxon_id, content_id)
    metadata = taxon_links_change(taxon_id, content_id)

    user = User.find_by(uid: metadata.dig("user_uid")) || User.new

    {
      depth: taxon_depth(taxon_id),
      url: metadata.dig("target", "base_path"),
      user_uid: metadata.dig("user_uid"),
      organisation_slug: user.organisation_slug,
    }
  end

  def taxon_links_change(taxon_id, content_id)
    changes = Services
      .publishing_api
      .get_links_changes(source_content_ids: [content_id],
                         link_types: ["taxons"])
      .to_h["link_changes"]

    changes.find { |link| link.dig("target", "content_id") == taxon_id } || {}
  end

  def taxon_depth(taxon_id)
    calculate_taxon_depth(
      Services.publishing_api.get_expanded_links(taxon_id).to_h
    )
  end

  def calculate_taxon_depth(taxon_hash, depth = 0)
    if taxon_hash.has_key?("links") && taxon_hash["links"].blank?
      depth
    else
      links = taxon_hash["expanded_links"] || taxon_hash["links"]
      calculate_taxon_depth(links["parent_taxons"].first, depth + 1)
    end
  end
end
