module Taxonomy
  class DeletePage
    include ActiveModel::Model

    delegate :content_id, :redirect_to, to: :taxon
    attr_reader :do_tag, :taxon

    def initialize(taxon)
      @taxon = taxon
      @do_tag = true
    end

    def taxonomy_tree
      @taxonomy_tree ||= Taxonomy::ExpandedTaxonomy.new(taxon.content_id).build
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
          fields: %w[title content_id base_path document_type],
        )
      end
    end

    def taxons_for_select
      Linkables.new.taxons(exclude_ids: taxon.content_id, include_draft: false)
    end
  end
end
