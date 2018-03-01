module Taxonomy
  class EditPage
    delegate :published?, to: :taxon

    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    def taxon_content_id
      taxon.content_id
    end

    def title
      taxon.internal_name
    end

    def taxons_for_select
      Linkables.new.taxons_including_root(exclude_ids: taxon.content_id)
    end

    def show_visibilty_checkbox?
      taxon.parent == GovukTaxonomy::ROOT_CONTENT_ID
    end
  end
end
