module Taxonomy
  class VersionHistoryPage
    attr_reader :taxon

    def initialize(taxon)
      @taxon = taxon
    end

    def title
      "Version history for #{taxon.title}"
    end

    def version_history
      Version.history(taxon.content_id).map { |v| VersionPresenter.new(v) }
    end
  end
end
