module Taxonomy
  class TaxonomyQuery
    TAXON_FIELDS = %w[content_id base_path title].freeze

    def initialize(fields = TAXON_FIELDS)
      @taxon_fields = (fields + ['base_path']).uniq
    end

    def root_taxons
      taxons = get_content_hash('/').dig('links', 'root_taxons') || []
      taxons.map { |taxon| taxon.slice(*@taxon_fields) }
    end

    def child_taxons(base_path)
      root_content_hash = get_content_hash(base_path)
      taxons = root_content_hash.dig('links', 'child_taxons') || []
      recursive_child_taxons(taxons, root_content_hash['content_id'])
    end

  private

    def recursive_child_taxons(taxons, parent_content_id)
      results = taxons.map { |taxon| taxon.slice(*@taxon_fields).merge('parent_content_id' => parent_content_id) }
      results + taxons.flat_map do |taxon|
        child_taxons = taxon.dig('links', 'child_taxons') || []
        recursive_child_taxons(child_taxons, taxon['content_id'])
      end
    end

    def get_content_hash(path)
      Services.content_store.content_item(path).to_h
    end
  end
end
