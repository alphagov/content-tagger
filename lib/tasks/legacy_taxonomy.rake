namespace :legacy_taxonomy do
  desc "Generates structure for mainstream browse at www.gov.uk/browse"
  task generate_mainstream_browse_page_taxons: :environment do
    taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/foo').to_taxonomy_branch
    LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').write(taxonomy)
  end

  desc "Generates structure for Topic taxonomy at www.gov.uk/browse"
  task generate_topic_taxons: :environment do
    taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/qux',
                                                      base_path: '/topic',
                                                      first_level_key: 'children',
                                                      second_level_key: 'children',
                                                      title: 'Topic Taxonomy').to_taxonomy_branch
    LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').write(taxonomy)
  end

  desc "Send the Mainstream Browse taxonomy to the publishing platform"
  task publish_mainstream_browse_page_taxons: :environment do
    taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').read
    LegacyTaxonomy::TaxonomyPublisher.new(taxonomy_branch).commit
  end

  desc "Send the Topic taxonomy to the publishing platform"
  task publish_topic_taxons: :environment do
    taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').read
    LegacyTaxonomy::TaxonomyPublisher.new(taxonomy_branch).commit
  end

  desc "Generates structure for Policy Areas at www.gov.uk/government/topics"
  task generate_policy_area_page_taxons: :environment do
    taxonomy = LegacyTaxonomy::PolicyAreaTaxonomy.new('/bar').to_taxonomy_branch
    LegacyTaxonomy::Yamlizer.new('tmp/policy_area.yml').write(taxonomy)
  end

  desc "Generates structure for Policy Areas / Policy"
  task generate_policy_area_and_policy_taxons: :environment do
    taxonomy = LegacyTaxonomy::PolicyTaxonomy.new('/baz').to_taxonomy_branch
    File.write('tmp/policy.yml', YAML.dump(taxonomy))
  end
end
