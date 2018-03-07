module Taxonomy
  class LinksUpdate
    def initialize(content_id:, parent_taxon_id: nil, associated_taxon_ids: [])
      @content_id = content_id
      @parent_taxon_id = parent_taxon_id.presence
      @associated_taxon_ids = Array(associated_taxon_ids).select(&:present?)
    end

    def call
      if @parent_taxon_id == GovukTaxonomy::ROOT_CONTENT_ID
        Services.publishing_api.patch_links(
          @content_id,
          links: {
            root_taxon: Array(@parent_taxon_id),
            parent_taxons: [],
            associated_taxons: @associated_taxon_ids,
          }
        )

      else
        Services.publishing_api.patch_links(
          @content_id,
          links: {
            root_taxon: [],
            parent_taxons: Array(@parent_taxon_id),
            associated_taxons: @associated_taxon_ids,
          }
        )
      end
    end
  end
end
