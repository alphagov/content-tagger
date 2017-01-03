module BulkTagging
  class SearchResponse
    attr_reader :gds_api_response, :gds_api_response_hash, :document_type

    def initialize(gds_api_response, document_type)
      @gds_api_response = gds_api_response
      @gds_api_response_hash = gds_api_response.to_hash
      @document_type = document_type
    end

    def results
      gds_api_response_hash['results'].map { |result| ContentItem.new(result) }
    end

    def current_page
      gds_api_response_hash['current_page']
    end

    def total_pages
      gds_api_response_hash['pages']
    end

    def limit_value
      5
    end
  end
end
