class Theme
  # TODO: remove these once no longer used in base paths
  ALPHA_TAXONOMY = '/alpha-taxonomy'.freeze
  OLD_EDUCATION_THEME_BASE_PATH = '/education-training-and-skills'.freeze

  EDUCATION_THEME_BASE_PATH = '/education'.freeze

  def self.taxon_path_prefixes
    [EDUCATION_THEME_BASE_PATH, OLD_EDUCATION_THEME_BASE_PATH, ALPHA_TAXONOMY]
  end
end
