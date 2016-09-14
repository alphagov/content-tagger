module BulkTagging
  class Search
    attr_reader :query, :document_type

    def self.default_document_types
      BulkTaggingSource.new.source_names
    end

    def initialize(query:, document_type:)
      @query = query
      @document_type = document_type
    end

    def self.perform(query:, document_type: default_document_types)
      new(query: query, document_type: document_type).perform
    end

    def perform
      SearchResponse.new(gds_response, document_type)
    end

  private

    def gds_response
      Services.publishing_api.get_content_items(
        document_type: document_type,
        per_page: 20,
        q: query
      )
    end
  end
end
