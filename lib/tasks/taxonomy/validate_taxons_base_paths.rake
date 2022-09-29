namespace :taxonomy do
  desc "Validates taxons against the URL structure (/highest-level-taxon-name/taxon-name)"
  task :validate_taxons_base_paths, [:and_fix] => [:environment] do |_task, args|
    # Extend the Publishing API timeout to allow for a
    # higher chance that the task will complete
    GdsApi::JsonClient::DEFAULT_TIMEOUT_IN_SECONDS = 10

    # [
    #   { "content_id"=>"91b8ef20-74e7-4552-880c-50e6d73c2ff9",
    #     "base_path"=>"/world/all",
    #     "title"=>"World" },
    #   ...
    # ]
    level_one_taxons = Taxonomy::TaxonomyQuery.new.level_one_taxons
    base_path_checker = TaxonBasePathStructureCheck.new(level_one_taxons:)
    base_path_checker.validate

    if base_path_checker.invalid_taxons.any?
      puts "-" * 36

      print "The following taxons did not match the taxon URL structure."
      print " Attempting to fix this..." if args[:and_fix].present?

      base_path_checker.invalid_taxons.each do |taxon|
        print "\n#{taxon.content_id} #{taxon.base_path}"

        next if args[:and_fix].blank?

        if taxon.level_one_taxon?
          puts ": skipping"
        else
          begin
            UpdateTaxonWorker.new.perform(taxon.content_id, base_path: taxon.valid_base_path)
            puts "\n  └─ #{taxon.valid_base_path}"
          rescue StandardError => e
            puts ": #{e.inspect}"
          end
        end
      end
    end
  end
end
