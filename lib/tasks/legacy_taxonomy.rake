namespace :legacy_taxonomy do
  desc "Generates structure for mainstream browse at www.gov.uk/browse"
  task generate_mainstream_browse_page_taxons: :environment do
    taxonomy = LegacyTaxonomy::MainstreamBrowseTaxonomy.new('/foo').to_taxonomy_branch
    File.write('tmp/msbp.yml', YAML.dump(taxonomy))
  end

  desc "Send the Mainstream Browse taxonomy to the publishing platform"
  task publish_mainstream_browse_page_taxons: :environment do
    # The psych YAML parser doesn't work with the Rails class autoloader.
    # And while there are more complicated ways of fixing this...
    _ = LegacyTaxonomy::TaxonData
    taxonomy_branch = YAML.load_file('tmp/msbp.yml')
    LegacyTaxonomy::TaxonomyWriter.new(taxonomy_branch).commit
  end
end
