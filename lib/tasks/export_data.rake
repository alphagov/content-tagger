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

  namespace :content do
    desc "Export all content items to file"
    task export: :environment do
      exporter = DataExport::ContentExport.new
      enum = exporter.content_links_enum.lazy.map { |link| exporter.get_content(link) }.reject(&:empty?)
      head = enum.first
      tail = enum.drop(1)
      File.open('tmp/content.json', 'w') do |f|
        f << "[ "
        f << JSON.dump(head) if head.present?
        tail.each_with_index do |taxon, index|
          f << ",\n"
          f << JSON.dump(taxon)
          puts "Documents exported: #{index}" if (index % 1000).zero?
        end
        f << "]\n"
      end
    end
  end
end
