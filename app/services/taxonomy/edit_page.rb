module Taxonomy
  class EditPage
    delegate :published?, to: :taxon

    attr_reader :taxon, :url_override_permission

    def initialize(taxon, url_override_permission = nil)
      @taxon = taxon
      @url_override_permission = url_override_permission
    end

    delegate :content_id, to: :taxon, prefix: true

    delegate :title, :url_override, to: :taxon

    def taxons_for_select
      Linkables.new.taxons_including_root(exclude_ids: taxon.content_id)
    end

    def show_visibilty_checkbox?
      taxon.parent_content_id == GovukTaxonomy::ROOT_CONTENT_ID
    end

    def show_url_override_input_field?
      url_override_permission
    end

    def show_url_override?
      url_override.present? && !show_url_override_input_field?
    end
  end
end
