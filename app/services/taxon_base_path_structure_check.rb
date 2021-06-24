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
    taxon = Taxon.new(taxon, level_one_prefix: level_one_prefix)

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

  class Taxon
    LEVEL_ONE_URL_REGEX = %r{^/([A-z0-9\-]+)$}.freeze

    def initialize(taxon, level_one_prefix:)
      @taxon = taxon
      @level_one_prefix = level_one_prefix
    end

    def valid?
      if level_one_taxon?
        LEVEL_ONE_URL_REGEX.match? base_path
      else
        return false if path_components.blank?

        level_one_prefix == path_components["prefix"]
      end
    end

    def content_id
      @taxon["content_id"]
    end

    def base_path
      @taxon["base_path"]
    end

    def level_one_taxon?
      @level_one_prefix.blank?
    end

    def level_one_prefix
      @level_one_prefix || path_components["prefix"]
    end

    def path_components
      @path_components ||= ::Taxon::PATH_COMPONENTS_REGEX.match base_path
    end

    def valid_base_path
      return base_path if valid?

      # Base path is a valid two segment path
      if path_components.present?
        "/#{level_one_prefix}/#{path_components['slug']}"
      else
        path_slug = @taxon["base_path"]
          .sub("/imported-topic/topic/", "")
          .sub("/imported-topic/", "")
          .sub("/imported-browse/browse/", "")
          .sub("/imported-browse/", "")
          .sub("/imported-policies/", "")
          .tr("/", "-")
        "/#{level_one_prefix}/#{path_slug}"
      end
    end
  end
end
