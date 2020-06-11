module BulkTagging
  class DocumentTypeTagger
    def self.call(taxon_content_id:, document_type:)
      new(taxon_content_id: taxon_content_id, document_type: document_type).call
    end

    def initialize(taxon_content_id:, document_type:)
      @taxon_content_id = taxon_content_id
      @document_type = document_type
    end

    def call
      # Ensure @taxon_content_id exists in the publishing api
      begin
        Services.publishing_api.get_content(@taxon_content_id)
      rescue GdsApi::HTTPNotFound
        raise
      end

      Services.publishing_api.get_content_items_enum(document_type: @document_type, fields: %w[content_id]).lazy.map do |document|
        content_id = document.fetch("content_id")
        new_taxons = add_taxon_link(content_id, @taxon_content_id)
        { status: "success", message: "success", content_id: content_id, new_taxons: new_taxons }
      rescue StandardError => e
        { status: "error", message: e.message, content_id: content_id, new_taxons: [] }
      end
    end

  private

    def add_taxon_link(content_id, taxon_content_id)
      response_hash = Services.publishing_api.get_links(content_id).to_h
      version = response_hash["version"]
      new_taxons = (Array.wrap(response_hash.dig("links", "taxons")) + [taxon_content_id]).uniq
      Services.publishing_api.patch_links(content_id, links: { taxons: new_taxons }, previous_version: version)
      new_taxons
    end
  end
end
