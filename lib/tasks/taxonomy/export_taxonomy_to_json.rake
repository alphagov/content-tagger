namespace :taxonomy do
  namespace :export do
    desc <<-DESC
    Exports an expanded taxonomy to a single JSON array
    DESC
    task :json, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)
      puts Taxonomy::TaxonTreeExport.new(root_taxon_id).build
    end

    desc 'Export Taxonomy tree to JSON file'
    task :to_file, %i[taxon_id file_name] => [:environment] do |_, args|
      file_name = args.fetch(:file_name, "taxon")

      taxon_id = args.fetch(:taxon_id)
      taxon_tree = Taxonomy::TaxonTreeExport.new(taxon_id).build

      open(Rails.root.join('tmp', "#{file_name}.json"), 'w') do |f|
        f << taxon_tree
      end
    end
  end
end
