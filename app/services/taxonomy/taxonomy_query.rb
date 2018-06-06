module Taxonomy
  class TaxonomyQuery
    TAXON_FIELDS = %w[content_id base_path title].freeze

    def initialize(fields = TAXON_FIELDS)
      @taxon_fields = (fields.map(&:to_s) + ['base_path']).uniq
    end

    def level_one_taxons
      taxons = get_content_hash('/').dig('links', 'level_one_taxons') || []
      taxons.map { |taxon| taxon.slice(*@taxon_fields) }
    end

    def child_taxons(base_path)
      root_content_hash = get_content_hash(base_path)
      taxons = root_content_hash.dig('links', 'child_taxons') || []
      recursive_child_taxons(taxons, root_content_hash['content_id'])
    end

    def taxons_per_level
      sibling_hashes = level_one_taxons.map { |h| get_content_hash(h['base_path']) }
      recursive_taxons_per_level([], sibling_hashes)
    end

    def content_tagged_to_taxons(content_ids, slice_size: 50)
      content_id_hashes = content_ids.each_slice(slice_size).flat_map do |chunk|
        Services.rummager.search_enum(filter_taxons: chunk, fields: ['content_id']).to_a
      end
      content_id_hashes.map { |h| h['content_id'] }.uniq
    end

    def parent(content_id)
      expanded_links = Services.publishing_api.get_expanded_links(content_id).to_h
      parent_taxon_hash = expanded_links.dig('expanded_links', 'parent_taxons', 0)
      parent_taxon_hash.nil? ? nil : parent_taxon_hash.slice(*@taxon_fields)
    end

  private

    def recursive_child_taxons(taxons, parent_content_id)
      results = taxons.map { |taxon| taxon.slice(*@taxon_fields).merge('parent_content_id' => parent_content_id) }
      results + taxons.flat_map do |taxon|
        child_taxons = taxon.dig('links', 'child_taxons') || []
        recursive_child_taxons(child_taxons, taxon['content_id'])
      end
    end

    def recursive_taxons_per_level(partial_results, sibling_hashes)
      return partial_results if sibling_hashes.empty?
      sibling_child_hashes = sibling_hashes.flat_map { |h| h.dig('links', 'child_taxons') }.compact
      taxons = sibling_hashes.map { |h| h.slice(*@taxon_fields) }
      recursive_taxons_per_level(partial_results + [taxons], sibling_child_hashes)
    end

    def get_content_hash(path)
      Services.content_store.content_item(path).to_h
    end
  end
end
