module ParentingChildcare
  class BuildTheme
    def self.build
      theme_params = {
        path_prefix: '/parenting-childcare',
        path_slug: '',
        internal_name: "Parenting, childcare and childrens services",
        title: "Parenting, childcare and childrens services",
        description: 'Health and welfare, financial help, finding a school, adoption, looked-after children, safeguarding.'
      }
      theme = Taxon.new(theme_params)
      puts "Creating theme '#{theme.title}'"
      Taxonomy::PublishTaxon.call(taxon: theme)

      theme
    end
  end
end
