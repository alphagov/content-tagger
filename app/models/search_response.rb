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

  def successful?
    gds_api_response.code == 200
  end

  def multiple_pages?
    gds_api_response_hash['pages'] > 1
  end
end
