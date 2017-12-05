module BulkTagging
  class DocumentTypeTagger
    def self.call(taxon_base_path:, document_type:)
      new(taxon_base_path: taxon_base_path, document_type: document_type).call
    end

    def initialize(taxon_base_path:, document_type:)
      @taxon_base_path = taxon_base_path
      @document_type = document_type
    end

    def call
      taxon_content_id = Services.publishing_api.lookup_content_id(base_path: @taxon_base_path)
      raise StandardError, "Cannot find taxon with base path #{@taxon_base_path}" if taxon_content_id.nil?

      Services.publishing_api.get_content_items_enum(document_type: @document_type, fields: ['content_id']).lazy.map do |document|
        begin
          content_id = document.fetch('content_id')
          new_taxons = add_taxon_link(content_id, taxon_content_id)
          { status: 'success', message: 'success', content_id: content_id, new_taxons: new_taxons }
        rescue StandardError => ex
          { status: 'error', message: ex.message, content_id: content_id, new_taxons: [] }
        end
      end
    end

  private

    def add_taxon_link(content_id, taxon_content_id)
      response_hash = Services.publishing_api.get_links(content_id).to_h
      version = response_hash['version']
      new_taxons = (Array.wrap(response_hash.dig('links', 'taxons')) + [taxon_content_id]).uniq
      Services.publishing_api.patch_links(content_id, links: { taxons: new_taxons }, previous_version: version)
      new_taxons
    end
  end
end
