module Tagging
  class Untagger
    def self.call(content_id, taxon_content_ids)
      new.untag(content_id, taxon_content_ids)
    end

    def untag(content_id, taxon_content_ids)
      existing_taxons_ids = Services.publishing_api.get_links(content_id).dig('links', 'taxons')
      Services.publishing_api.patch_links(content_id, links: { taxons: (existing_taxons_ids - taxon_content_ids) })
    end
  end
end
