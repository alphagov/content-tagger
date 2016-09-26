module BulkTagging
  class FetchTaggedContent
    def self.call(tag_content_id:, tag_document_type:)
      new(tag_content_id, tag_document_type).call
    end

    attr_reader :content_id, :document_type

    def initialize(content_id, document_type)
      @content_id = content_id
      @document_type = document_type
    end

    def call
      request_tagged_content_items
    end

  private

    def request_tagged_content_items
      results = Services.publishing_api.get_linked_items(
        content_id,
        link_type: document_type,
        fields: %w(title content_id base_path document_type)
      )

      results.map { |result| ContentItem.new(result) }
    end
  end
end
