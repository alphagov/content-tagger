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
      Linkables.new.taxons(exclude_ids: taxon.content_id)
    end

    def path_prefixes_for_select
      Theme.taxon_path_prefixes
    end

    def show_visibilty_checkbox?
      taxon.draft? && taxon.parent_taxons.empty?
    end
  end
end
