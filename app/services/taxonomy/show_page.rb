module Taxonomy
  class ShowPage
    delegate :content_id, :draft?, :published?, :unpublished?, :redirected?,
             :redirect_to, :base_path, to: :taxon

    attr_reader :taxon, :visualisation

    def initialize(taxon, visualisation = "taxonomy_tree")
      @taxon = taxon
      @visualisation = visualisation
    end

    def title
      taxon.internal_name
    end

    def publication_state_name
      {
        "draft" => "Draft",
        "published" => "Published",
        "unpublished" => "Deleted",
      }.fetch(taxon.publication_state)
    end

    def taxon_content_id
      taxon.content_id
    end

    def taxonomy_tree
      @taxonomy_tree ||= Taxonomy::ExpandedTaxonomy.new(taxon_content_id).build
    end

    def taxonomy_size
      @taxonomy_size ||= Taxonomy::TaxonomySizePresenter.new(
        Taxonomy::TaxonomySize.new(taxon)
      )
    end

    def children
      @children ||= taxonomy_tree.child_expansion.children
    end

    def tagged
      @tagged ||= begin
        return [] if taxon.unpublished?

        Services.publishing_api.get_linked_items(
          taxon.content_id,
          link_type: "taxons",
          fields: %w[title content_id base_path document_type]
        )
      end
    end

    def taxons_for_select
      Linkables.new.taxons(exclude_ids: taxon_content_id)
    end

    def associated_taxons
      taxonomy_tree.associated_taxons
    end
  end
end
