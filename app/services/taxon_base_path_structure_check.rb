class TaxonBasePathStructureCheck
  attr_reader :path_validation_output, :invalid_taxons

  def initialize(level_one_taxons:)
    @level_one_taxons = level_one_taxons
    @invalid_taxons = []
  end

  def validate
    @level_one_taxons.each { |level_one_taxon| validate_tree(taxon: level_one_taxon) }
  end

private

  # rubocop:disable Rails/Output
  def validate_tree(taxon:, level_one_prefix: nil, n: 0) # rubocop:disable Naming/MethodParameterName
    taxon = Taxon.new(taxon, level_one_prefix:)

    spacer = n.positive? ? "#{' ' * n * 2} ├── " : ""
    if taxon.valid?
      puts "✅ #{spacer}#{taxon.base_path}"
    else
      puts "❌ #{spacer}#{taxon.base_path}"
      @invalid_taxons << taxon
    end

    next_level_taxons = taxonomy_query.child_taxons(taxon.base_path)

    return unless next_level_taxons.any?

    next_level_taxons.each do |next_level_taxon|
      validate_tree(taxon: next_level_taxon, level_one_prefix: taxon.level_one_prefix, n: n + 1)
    end
  end
  # rubocop:enable Rails/Output

  def taxonomy_query
    @taxonomy_query ||= Taxonomy::TaxonomyQuery.new
  end
end
