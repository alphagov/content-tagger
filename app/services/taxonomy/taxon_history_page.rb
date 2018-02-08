module Taxonomy
  class TaxonHistoryPage
    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    def title
      "History for #{taxon.title}"
    end

    def version_history
      Version.history(taxon.content_id).map { |v| VersionPresenter.new(v) }
    end
  end
end
