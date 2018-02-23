class TaxonBasePathStructureCheck
  LEVEL_ONE_URL_REGEX = %r{^\/([A-z0-9\-]+)$}
  PATH_COMPONENTS_REGEX = %r{^\/(?<prefix>[A-z0-9\-]+)(\/(?<slug>[A-z0-9\-]+))?$}

  attr_reader :path_validation_output, :invalid_taxons

  def initialize(level_one_taxons:)
    @level_one_taxons = level_one_taxons
    @path_validation_output = []
    @invalid_taxons = []
  end

  def validate
    @level_one_taxons.each do |level_one_taxon|
      base_path = level_one_taxon['base_path']

      if LEVEL_ONE_URL_REGEX.match?(base_path)
        @path_validation_output << "✅ #{base_path}"
      else
        @invalid_taxons << level_one_taxon
        @path_validation_output << "❌ #{base_path}"
      end

      level_one_prefix = PATH_COMPONENTS_REGEX.match(base_path)['prefix']

      taxonomy_query
        .child_taxons(base_path)
        .each do |level_two_taxon|
          validate_taxon(
            level_one_prefix: level_one_prefix,
            taxon: level_two_taxon
          )
        end
    end
  end

private

  def taxonomy_query
    @_taxonomy_query ||= Taxonomy::TaxonomyQuery.new
  end

  def validate_taxon(level_one_prefix:, taxon:, n: 1)
    base_path = taxon['base_path']
    path_components = PATH_COMPONENTS_REGEX.match(base_path)

    if path_components.present?
      if level_one_prefix == path_components['prefix']
        @path_validation_output << "✅ #{' ' * n * 2} ├── #{base_path}"
      else
        @invalid_taxons << taxon
        @path_validation_output << "❌ #{' ' * n * 2} ├── #{base_path}"
      end
    else
      @invalid_taxons << taxon
      @path_validation_output << "❌ #{' ' * n * 2} ├── #{base_path}"
    end

    next_level_taxons = taxonomy_query.child_taxons(base_path)

    return unless next_level_taxons.any?

    next_level_taxons.each do |next_level_taxon|
      validate_taxon(
        level_one_prefix: level_one_prefix,
        taxon: next_level_taxon,
        n: n + 1
      )
    end
  end
end
