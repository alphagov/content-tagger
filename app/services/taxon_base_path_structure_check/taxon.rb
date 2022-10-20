class TaxonBasePathStructureCheck::Taxon
  LEVEL_ONE_URL_REGEX = %r{^/([A-z0-9\-]+)$}

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
