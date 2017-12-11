module Taxonomy
  class TaggedContentPage
    delegate :content_id, :draft?, :published?, :unpublished?, :redirected?,
             :redirect_to, :base_path, to: :taxon

    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    def taxon_content_id
      taxon.content_id
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
  end
end
