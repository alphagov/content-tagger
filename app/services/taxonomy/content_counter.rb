module Taxonomy
  class ContentCounter
    def self.count(taxon_content_id)
      Services.search_api.search(
        filter_taxons: taxon_content_id,
        count: 0,
        reject_content_store_document_type: Tagging.blacklisted_document_types
      ).to_h.fetch('total', 0)
    end
  end
end
