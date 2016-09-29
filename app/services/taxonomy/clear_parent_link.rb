module Taxonomy
  class ClearParentLink
    def self.call(content_id)
      taxon_parent_links_update = TaxonParentLinksUpdate.new(content_id)

      PublishLinks.call(links_update: taxon_parent_links_update)
    end
  end
end
