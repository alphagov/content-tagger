namespace :taxonomy do
  desc "Validates taxons against the URL structure (/highest-level-taxon-name/taxon-name)"
  task validate_taxons_base_paths: :environment do
    # [
    #   { "content_id"=>"91b8ef20-74e7-4552-880c-50e6d73c2ff9",
    #     "base_path"=>"/world/all",
    #     "title"=>"World" },
    #   ...
    # ]
    level_one_taxons = Taxonomy::TaxonomyQuery.new.level_one_taxons
    base_path_checker = TaxonBasePathStructureCheck.new(level_one_taxons: level_one_taxons)
    base_path_checker.validate

    if base_path_checker.invalid_taxons.any?
      puts "-" * 36

      puts "The following taxons do not follow the taxon URL structure:"
      base_path_checker.invalid_taxons.each do |taxon|
        puts "#{taxon.content_id} #{taxon.base_path}"
      end
    end
  end
end
