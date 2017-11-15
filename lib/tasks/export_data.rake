namespace :export_data do
  namespace :taxons do
    desc "Export all taxons to file"
    task export: :environment do
      exporter = DataExport::TaxonExport.new
      root_taxons = exporter.root_taxons
      result = root_taxons + root_taxons.flat_map { |t| exporter.child_taxons(t['base_path']) }

      open('tmp/taxons.json', 'w') do |f|
        f << JSON.dump(result)
      end
    end
  end
end
