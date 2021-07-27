class TaggedContentExporter
  def initialize(content_items)
    @content_items = content_items
  end

  def content_items_with_taxons
    @content_items.map do |content_item|
      {
        content_id: content_item.content_id,
        url: content_item.url.gsub("https://www.gov.uk", ""),
        taxons: taxons_for(content_item).compact,
      }
    end
  end

private

  def taxons_for(content_item)
    links = Services.publishing_api.get_links(content_item.content_id).to_h
    (links.dig("links", "taxons") || []).map do |taxon_id|
      {
        content_id: taxon_id,
      }.merge(metadata_for_taxon(taxon_id, content_item.content_id))
    end
  end

  def metadata_for_taxon(taxon_id, content_id)
    metadata = taxon_links_change(taxon_id, content_id)

    user = User.find_by(uid: metadata["user_uid"]) || User.new

    {
      url: metadata.dig("target", "base_path"),
      user_uid: metadata["user_uid"],
      organisation_slug: user.organisation_slug,
    }.merge(tree_data_for_taxon(taxon_id))
  end

  def taxon_links_change(taxon_id, content_id)
    changes = Services
      .publishing_api
      .get_links_changes(source_content_ids: [content_id],
                         link_types: %w[taxons])
      .to_h["link_changes"]

    changes.find { |link| link.dig("target", "content_id") == taxon_id } || {}
  end

  def tree_data_for_taxon(taxon_id)
    links = Services.publishing_api.get_expanded_links(taxon_id).to_h
    initial_tree_data = { depth: 0, path: [] }
    calculate_taxon_depth_and_path(links, initial_tree_data)
  end

  def calculate_taxon_depth_and_path(taxon_hash, tree_data = {})
    if taxon_hash.key?("links") && taxon_hash["links"].blank?
      tree_data[:path] = Array(taxon_hash["title"]).concat(tree_data[:path]).join(" / ")
      tree_data
    else
      links = taxon_hash["expanded_links"] || taxon_hash["links"]
      title = taxon_hash["title"] || title_from_translations(taxon_hash)

      tree_data[:depth] += 1
      tree_data[:path].unshift(title)

      calculate_taxon_depth_and_path(links["parent_taxons"].first, tree_data)
    end
  end

  def title_from_translations(taxon_hash)
    translations = taxon_hash.dig("expanded_links", "available_translations")
    return if translations.blank?

    (translations.find { |h| h["title"].present? } || {})["title"]
  end
end
