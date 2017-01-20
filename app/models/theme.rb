class Theme
  ALPHA_TAXONOMY = '/alpha-taxonomy'.freeze # TODO: remove once all base paths have been updated
  EDUCATION_THEME_BASE_PATH = '/education-training-and-skills'.freeze

  def self.taxon_path_prefixes
    [EDUCATION_THEME_BASE_PATH, ALPHA_TAXONOMY]
  end
end
