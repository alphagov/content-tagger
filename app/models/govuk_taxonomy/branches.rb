module GovukTaxonomy
  class Branches
    def branch_name_for_content_id(content_id)
      get_content_item(content_id)["title"]
    end

    def all
      Taxonomy::LevelOneTaxonsRetrieval.new.get(with_drafts: true)
        .map { |taxon| taxon.slice("content_id", "title", "base_path") }
    end

    def taxons_for_branch(content_id)
      taxon = get_content_item(content_id)
      taxon["expanded_links_hash"] = get_expanded_links_hash(content_id, with_drafts: true)
      Tree.new(taxon).root_taxon.tree
    end

  private

    def get_expanded_links_hash(content_id, with_drafts:)
      Services.publishing_api
        .get_expanded_links(content_id, with_drafts: with_drafts)
        .to_h
    end

    def get_content_item(content_id)
      Services.publishing_api.get_content(content_id).to_h
    end
  end
end
