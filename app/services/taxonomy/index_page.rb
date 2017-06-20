module Taxonomy
  class IndexPage
    attr_reader :params, :state

    def initialize(params, state)
      @params = params
      @state = state
    end

    def search_results
      remote_taxons.search(
        page: params[:page],
        per_page: params[:per_page],
        query: query,
        states: [state],
      )
    end

    def taxons
      search_results.taxons
    end

    def query
      params[:q]
    end

  private

    def remote_taxons
      @remote_taxons ||= RemoteTaxons.new
    end
  end
end
