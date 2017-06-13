module Taxonomy
  class HistoryPage
    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    def title
      taxon.internal_name
    end

    def taxon_content_id
      taxon.content_id
    end

    def tagging_events
      @_tagging_events ||= TaggingEvent.for_taxon_id(taxon_content_id).order(tagged_at: :desc)
    end
  end
end
