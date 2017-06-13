module Analytics
  class IndexPage
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def taxons
      TaggingEvent.content_counts_by_taxon
    end

  private

    def remote_taxons
      @remote_taxons ||= RemoteTaxons.new
    end
  end
end
