module EducationTaxonNamer
  def self.rename_taxon(taxon)
    slug = slug_from_title(taxon)
    taxon.base_path = make_base_path(slug)
  end

  def self.make_base_path(slug)
    if slug_is_theme_root?(slug)
      Theme::EDUCATION_THEME_BASE_PATH
    else
      Theme::EDUCATION_THEME_BASE_PATH + slug
    end
  end

  def self.slug_is_theme_root?(slug)
    [
      Theme::OLD_EDUCATION_THEME_BASE_PATH,
      Theme::EDUCATION_THEME_BASE_PATH
    ].include?(slug)
  end

  def self.slug_from_title(taxon)
    parent = RemoteTaxons.new.parents_for_taxon(taxon).first

    if title_ambiguous?(taxon.title)
      "/#{parent.title.parameterize}-#{taxon.title.parameterize}"
    else
      "/#{taxon.title.parameterize}"
    end
  end

  def self.title_ambiguous?(title)
    [
      "Assessments",
      "Tests",
      "Programmes of study",
      "Science",
      "Maths",
      "English"
    ].include?(title)
  end
end
