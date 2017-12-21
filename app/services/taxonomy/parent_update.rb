module Taxonomy
  class ParentUpdate
    def set_parent(content_id, parent_taxon_id: nil, associated_taxon_ids: nil)
      if parent_taxon_id == GovukTaxonomy::ROOT_CONTENT_ID
        update(content_id, parent_taxon_id, nil, associated_taxon_ids)
      else
        update(content_id, nil, parent_taxon_id, associated_taxon_ids)
      end
    end

  private

    def update(content_id, root_taxon, parent_taxon_id, associated_taxon_ids)
      Services.publishing_api.patch_links(content_id, links: { root_taxon: root_taxon.present? ? [root_taxon] : [],
                                                               parent_taxons: parent_taxon_id.present? ? [parent_taxon_id] : [],
                                                               associated_taxons: associated_taxon_ids.present? ? associated_taxon_ids : [] })
    end
  end
end
