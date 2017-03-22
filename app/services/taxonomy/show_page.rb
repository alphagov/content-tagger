module Taxonomy
  class ShowPage
    delegate :content_id, :draft?, :published?, :unpublished?, to: :taxon

    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
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

    def children
      @children ||= taxonomy_tree.child_expansion.children
    end

    def tagged
      @tagged ||= begin
        return [] if taxon.unpublished?

        Services.publishing_api.get_linked_items(
          taxon.content_id,
          link_type: "taxons",
          fields: %w(title content_id base_path document_type)
        )
      end
    end
  end
end
