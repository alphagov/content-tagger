class ExpandedLinksFetcher
  def self.expanded_links(content_id, document_type)
    new(content_id, document_type).call
  end

  attr_reader :content_id, :document_type

  def initialize(content_id, document_type)
    @content_id = content_id
    @document_type = document_type
  end

  def call
    api_response = Services.publishing_api.get_expanded_links(content_id)
    results = api_response['expanded_links'].fetch(
      BulkTaggingSource.new.content_key_for(document_type), []
    )
    results.map { |result| ContentItem.new(result) }
  end
end
