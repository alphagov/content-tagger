class ExpandedLinksFetcher
  def self.expanded_links(content_id)
    gds_response = Services.publishing_api.get_expanded_links(content_id)
    documents = gds_response['expanded_links']['documents']
    documents.map { |result| ContentItem.new(result) }
  end
end
