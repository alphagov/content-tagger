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
      if taxon_document_type?
        request_tagged_content_to_taxon
      else
        request_tagged_content_items
      end
    end

  private

    def taxon_document_type?
      document_type == "taxon"
    end

    def request_tagged_content_to_taxon
      results = Services.publishing_api.get_linked_items(
        content_id,
        link_type: "taxons",
        fields: %w(title content_id base_path document_type)
      )

      results.map { |result| ContentItem.new(result) }
    end

    def request_tagged_content_items
      api_response = Services.publishing_api.get_expanded_links(content_id)
      results = api_response['expanded_links'].fetch(
        BulkTaggingSource.new.content_key_for(document_type), []
      )
      results.map { |result| ContentItem.new(result) }
    end
  end
end
