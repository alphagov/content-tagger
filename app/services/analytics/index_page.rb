module Analytics
  class IndexPage
    def taxons
      TaggingEvent.content_counts_by_taxon
    end
  end
end
