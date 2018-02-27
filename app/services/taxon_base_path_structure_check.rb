class TaxonBasePathStructureCheck
  attr_reader :path_validation_output, :invalid_taxons

  def initialize(level_one_taxons:)
    @level_one_taxons = level_one_taxons
    @path_validation_output = []
    @invalid_taxons = []
  end

  def validate
    @level_one_taxons.each { |level_one_taxon| validate_tree(taxon: level_one_taxon) }
  end

private

  def validate_tree(taxon:, level_one_prefix: nil, n: 0)
    taxon = Taxon.new(taxon, level_one_prefix: level_one_prefix)

    spacer = n.positive? ? "#{' ' * n * 2} ├── " : ""
    if taxon.valid?
      @path_validation_output << "✅ #{spacer}#{taxon.base_path}"
    else
      @path_validation_output << "❌ #{spacer}#{taxon.base_path}"
      @invalid_taxons << taxon
    end

    next_level_taxons = taxonomy_query.child_taxons(taxon.base_path)

    return unless next_level_taxons.any?

    next_level_taxons.each do |next_level_taxon|
      validate_tree(taxon: next_level_taxon, level_one_prefix: taxon.level_one_prefix, n: n + 1)
    end
  end

  def taxonomy_query
    @_taxonomy_query ||= Taxonomy::TaxonomyQuery.new
  end

  class Taxon
    LEVEL_ONE_URL_REGEX = %r{^\/([A-z0-9\-]+)$}
    PATH_COMPONENTS_REGEX = %r{^\/(?<prefix>[A-z0-9\-]+)(\/(?<slug>[A-z0-9\-]+))?$}

    def initialize(taxon, level_one_prefix:)
      @taxon = taxon
      @level_one_prefix = level_one_prefix
    end

    def valid?
      if level_one_taxon?
        LEVEL_ONE_URL_REGEX.match? base_path
      else
        return false if path_components.blank?
        level_one_prefix == path_components['prefix']
      end
    end

    def base_path
      @taxon['base_path']
    end

    def level_one_taxon?
      @level_one_prefix.blank?
    end

    def level_one_prefix
      @level_one_prefix || path_components['prefix']
    end

    def path_components
      @_path_components ||= PATH_COMPONENTS_REGEX.match base_path
    end
  end
end
