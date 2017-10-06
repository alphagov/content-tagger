class TaggedContentExporter
  def self.call
    transport_taxon_id = "a4038b29-b332-4f13-98b1-1c9709e216bc"
    content_items = ProjectContentItem.for_taxonomy_branch(transport_taxon_id).done

    content_items = content_items.map do |c|
      puts c.content_id

      content_item = {}
      content_item["content_id"] = c.content_id
      content_item["url"] = c.url.gsub("https://www.gov.uk", "")
      response = Services.publishing_api.get_links(c.content_id)

      if response.to_h["links"]["taxons"].blank?
        puts "--FAIL no taxons in links hash"
        next
      end

      content_item["taxons"] = response.to_h["links"]["taxons"].map do |taxon_id|
        puts "--#{taxon_id}"

        params = { source_content_ids: [c.content_id], link_types: ["taxons"] }
        taxon_change = Services
          .publishing_api
          .get_links_changes(params)
          .to_h["link_changes"]
          .find { |link| link.dig("target", "content_id") == taxon_id }

        if taxon_change.blank?
          puts "--FAIL taxon_change is blank"
          next
        end

        user = User.find_by(uid: taxon_change.dig("user_uid")) || User.new
        taxon_hash = Services.publishing_api.get_expanded_links(taxon_id).to_h

        {
          content_id: taxon_id,
          depth: self.taxon_depth(taxon_hash),
          url: taxon_change.dig("target", "base_path"),
          user_uid: taxon_change.dig("user_uid"),
          organisation_slug: user.organisation_slug,
        }
      end.compact

      content_item
    end.compact

    content_items
  end

  def self.taxon_depth(taxon_hash, depth = 0)
    if taxon_hash.has_key?("links") && taxon_hash["links"].blank?
      depth
    else
      if taxon_hash.has_key? "links"
        taxon_depth(taxon_hash["links"]["parent_taxons"].first, depth + 1)
      elsif taxon_hash.has_key? "expanded_links"
        taxon_depth(taxon_hash["expanded_links"]["parent_taxons"].first, depth + 1)
      end
    end
  end
end
