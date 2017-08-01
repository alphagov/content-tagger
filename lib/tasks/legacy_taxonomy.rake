namespace :legacy_taxonomy do
  namespace :all do
    desc "Scrape and import legacy taxonomies"
    task import: :environment do
      taxonomies = %w(mainstream_browse topic)
      tasks = %w(generate_taxons publish_taxons)

      tasks.each do |tsk|
        taxonomies.each do |taxonomy|
          Rake::Task["legacy_taxonomy:#{taxonomy}:#{tsk}"].execute
        end
      end
    end
  end

  namespace :mainstream_browse do
    desc "Generates structure for mainstream browse at www.gov.uk/browse"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/imported-browse').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').write(taxonomy)
    end

    desc "Send the Mainstream Browse taxonomy to the publishing platform"
    task publish_taxons: :environment do
      Theme.find_or_create_by(name: 'Mainstream Browse', path_prefix: '/imported-browse')
      taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').as_yaml
      LegacyTaxonomy::TaxonomyPublisher.perform_async(taxonomy_branch)
    end
  end

  namespace :topic do
    desc "Generates structure for Topic taxonomy at www.gov.uk/browse"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/imported-topic',
                                                        base_path: '/topic',
                                                        first_level_key: 'children',
                                                        second_level_key: 'children',
                                                        title: 'Topic Taxonomy').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').write(taxonomy)
    end

    desc "Send the Topic taxonomy to the publishing platform"
    task publish_taxons: :environment do
      Theme.find_or_create_by(name: 'Topic', path_prefix: '/imported-topic')
      taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').as_yaml
      LegacyTaxonomy::TaxonomyPublisher.perform_async(taxonomy_branch)
    end
  end

  namespace :policy_area do
    desc "Generates structure for Policy Areas at www.gov.uk/government/topics"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::PolicyAreaTaxonomy.new('/bar').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/policy_area.yml').write(taxonomy)
    end
  end

  namespace :policy do
    desc "Generates structure for Policy Areas => Policy"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::PolicyTaxonomy.new('/baz').to_taxonomy_branch
      File.write('tmp/policy.yml', YAML.dump(taxonomy))
    end
  end

  namespace :statistics do
    desc "Generate taxonomy statistics CSV"
    task generate: :environment do
      _ = LegacyTaxonomy::TaxonData
      %w(msbp policy_area policy).each do |tax|
        taxonomy = YAML.load_file("tmp/#{tax}.yml")
        taxons_array = LegacyTaxonomy::Statistics.new(taxonomy).to_a
        CSV.open("tmp/#{tax}.csv", "wb") do |csv|
          csv << taxons_array.first.keys
          taxons_array.each { |hash| csv << hash.values }
        end
      end
    end
  end
end
