class WorldwideTaxonPresenter
  attr_reader :country, :generic_taxon, :taxons

  def initialize(country, generic_taxon, taxons)
    @country = country
    @generic_taxon = generic_taxon
    @taxons = taxons
  end

  def present
    {
      path_prefix: "/world",
      path_slug: slug,
      internal_name: internal_name,
      title: title,
      description: description,
      visible_to_departmental_editors: true,
      notes_for_editors: "",
      parent: country_parent_taxon_content_id,
      associated_taxons: [
        generic_taxon[:content_id]
      ],
    }
  end

private

  def slug
    if generic_taxon[:slug].ends_with?('COUNTRY')
      "/#{generic_taxon[:slug].gsub('COUNTRY', country[:slug])}"
    else
      "/#{generic_taxon[:slug]}-#{country[:slug]}"
    end
  end

  def internal_name
    if generic_taxon[:title].ends_with?('COUNTRY')
      generic_taxon[:title].gsub('COUNTRY', country[:name])
    else
      "#{generic_taxon[:title]} (#{country[:name]})"
    end
  end

  def title
    generic_taxon[:title].gsub('COUNTRY', country[:name])
  end

  def description
    generic_taxon[:description].gsub('COUNTRY', country[:name])
  end

  def country_parent_taxon_content_id
    country_parent_taxon["content_id"] if country_parent_taxon
  end

  def country_parent_taxon
    taxons.find { |t| t["base_path"] == "/world/#{country[:slug]}" }
  end
end
