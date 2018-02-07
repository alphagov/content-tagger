module Taxonomy
  class TaxonTreeExport
    attr_reader :taxon_content_id

    def initialize(content_id)
      @taxon_content_id = content_id
    end

    def expanded_taxon
      top_taxon = content_struct(taxon_content_id)
      Taxonomy::ExpandedTaxonomy.new(top_taxon.content_id)
    end

  private

    def content_struct(content_id)
      OpenStruct.new(Services.publishing_api.get_content(content_id).to_h)
    end
  end
end
