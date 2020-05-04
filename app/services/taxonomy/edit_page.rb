module Taxonomy
  class EditPage
    delegate :published?, to: :taxon

    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    delegate :content_id, to: :taxon, prefix: true

    delegate :title, to: :taxon

    def taxons_for_select
      Linkables.new.taxons_including_root(exclude_ids: taxon.content_id)
    end

    def show_visibilty_checkbox?
      taxon.parent_content_id == GovukTaxonomy::ROOT_CONTENT_ID
    end
  end
end
