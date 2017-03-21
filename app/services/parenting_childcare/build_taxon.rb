module ParentingChildcare
  class BuildTaxon
    def self.build(title:, description:, prefix:)
      taxon_params = {
        path_prefix: prefix,
        path_slug: "/" + title.strip.downcase.tr(" ", "-").gsub(/[^\w-]/, ''),
        internal_name: title,
        title: title,
        description: description || 'TBC'
      }

      taxon = Taxon.new(taxon_params)
      puts " => Creating '#{taxon.title}'"

      Taxonomy::UpdateTaxon.call(taxon: taxon)

      taxon
    end
  end
end
