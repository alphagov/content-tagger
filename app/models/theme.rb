class Theme
  THEMES = {
    '/childcare-parenting' => 'Childcare and Parenting',
    '/education' => 'Education',
    '/world' => 'World',
  }.freeze

  def self.taxon_path_prefixes
    THEMES.keys
  end
end
