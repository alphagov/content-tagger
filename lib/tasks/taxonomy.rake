namespace :taxonomy do
  desc "Delete all taxon links for the list of taxon base paths set in the environment"
  task delete_links: :environment do
    base_paths = ENV.fetch("TAXON_CLEANUP").split(",")
    AlphaTaxonomy::TaxonLinkDeleter.new(base_paths: base_paths).run!
  end

  desc "Generate the import file from the taxonomy sheets specified in the environment"
  task import_file: :environment do
    sheet_identifiers = ENV.fetch("TAXON_SHEETS").split(',')
    AlphaTaxonomy::ImportFile.new(sheet_identifiers: sheet_identifiers).populate
  end

  desc "Read the import file and create any new taxons found within"
  task create_taxons: :environment do
    AlphaTaxonomy::TaxonCreator.new.run!
  end

  desc "Read the import file and create all the taxon links specified"
  task link_taxons: :environment do
    AlphaTaxonomy::TaxonLinker.new.run!
  end

  desc "Run the complete bulk import process end-to-end"
  task bulk_import: :environment do
    # Note that this task is simply a wrapper for the discrete stages of the bulk
    # import process. It makes no effort to clear pre-existing taxon links that
    # no longer appear in the import file.
    Rake::Task["taxonomy:import_file"].invoke
    Rake::Task["taxonomy:create_taxons"].invoke
    Rake::Task["taxonomy:link_taxons"].invoke
  end
end
