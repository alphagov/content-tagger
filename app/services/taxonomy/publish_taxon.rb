module Taxonomy
  class PublishTaxon
    def initialize(taxon)
      @taxon = taxon
    end

    def self.call(taxon)
      new(taxon).publish
    end

    def publish
      if @taxon.parent.nil? && @taxon.visible_to_departmental_editors == false
        @taxon.visible_to_departmental_editors = true
        Taxonomy::UpdateTaxon.call(taxon: @taxon)
      end

      Services.publishing_api.publish(@taxon.content_id)
    end
  end
end
