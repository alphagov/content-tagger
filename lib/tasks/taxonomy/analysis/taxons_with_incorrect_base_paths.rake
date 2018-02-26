namespace :taxonomy do
  namespace :analysis do
    desc "Outputs taxons that do not follow the defined taxon URL structure"
    task taxons_with_incorrect_base_paths: :environment do
      # [
      #   { "content_id"=>"91b8ef20-74e7-4552-880c-50e6d73c2ff9",
      #     "base_path"=>"/world/all",
      #     "title"=>"World" },
      #   ...
      # ]
      level_one_taxons = Taxonomy::TaxonomyQuery.new.level_one_taxons

      base_path_checker = TaxonBasePathStructureCheck.new(level_one_taxons: level_one_taxons)
      base_path_checker.validate

      puts base_path_checker.path_validation_output.join("\n")

      puts "-" * 36

      puts "The following taxons do not follow the taxon URL structure:"
      base_path_checker.invalid_taxons.each do |taxon|
        puts taxon.slice('content_id', 'base_path').values.join(' ')
      end
    end
  end
end
