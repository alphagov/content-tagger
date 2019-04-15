module Facets
  class FacetsTaggingNotificationPresenter
    attr_reader :document, :change_note, :links, :tags

    def initialize(document, change_note, links = {}, tags = {})
      @document = document
      @change_note = change_note
      @links = links
      @tags = tags
    end

    def present
      {
        base_path: document.base_path,
        change_note: change_note,
        content_id: document.content_id,
        description: document.description,
        document_type: document.document_type,
        email_document_supertype: "other",
        government_document_supertype: "other",
        links: links,
        priority: "high",
        public_updated_at: Time.now.iso8601,
        publishing_app: "content-tagger",
        subject: document.title,
        tags: tags,
        title: document.title,
        urgent: true,
      }
    end
  end
end
