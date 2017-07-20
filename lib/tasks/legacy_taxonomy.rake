namespace :legacy_taxonomy do
  desc "Generates structure for mainstream browse at www.gov.uk/browse"
  task generate_mainstream_browse_page_taxons: :environment do
    taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/foo').to_taxonomy_branch
    File.write('tmp/msbp.yml', YAML.dump(taxonomy))
  end

  desc "Generates structure for Topic taxonomy at www.gov.uk/browse"
  task generate_topic_taxons: :environment do
    taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/foo',
                                                      base_path: '/topic',
                                                      first_level_key: 'children',
                                                      second_level_key: 'children',
                                                      title: 'Topic Taxonomy').to_taxonomy_branch
    File.write('tmp/topic.yml', YAML.dump(taxonomy))
  end

  desc "Send the Mainstream Browse taxonomy to the publishing platform"
  task publish_mainstream_browse_page_taxons: :environment do
    # The psych YAML parser doesn't work with the Rails class autoloader.
    # And while there are more complicated ways of fixing this...
    _ = LegacyTaxonomy::TaxonData
    taxonomy_branch = YAML.load_file('tmp/msbp.yml')
    LegacyTaxonomy::TaxonomyWriter.new(taxonomy_branch).commit
  end

  desc "Send the Topic taxonomy to the publishing platform"
  task publish_topic_taxons: :environment do
    # The psych YAML parser doesn't work with the Rails class autoloader.
    # And while there are more complicated ways of fixing this...
    _ = LegacyTaxonomy::TaxonData
    taxonomy_branch = YAML.load_file('tmp/topic.yml')
    LegacyTaxonomy::TaxonomyWriter.new(taxonomy_branch).commit
  end
end
