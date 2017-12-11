module BulkTagging
  class Search
    attr_reader :query, :page, :document_type

    def self.default_document_types
      BulkTaggingSource.new.source_names
    end

    def initialize(query:, page:, document_type:)
      @query = query
      @page = page
      @document_type = document_type
    end

    def self.call(query:, page:, document_type: default_document_types)
      new(query: query, document_type: document_type, page: page).call
    end

    def call
      SearchResponse.new(gds_response, document_type)
    end

  private

    def gds_response
      Services.publishing_api.get_content_items(
        document_type: document_type,
        page: page,
        q: query,
        fields: %i[content_id document_type title base_path],
        search_in: %i[title base_path details.internal_name]
      )
    end
  end
end
