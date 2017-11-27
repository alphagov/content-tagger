namespace :export_data do
  namespace :taxons do
    desc "Export all taxons to file"
    task export: :environment do
      query = Taxonomy::TaxonomyQuery.new
      root_taxons = query.root_taxons
      result = root_taxons + root_taxons.flat_map { |t| query.child_taxons(t['base_path']) }

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

    desc "Get number of documents per document type omitted in the document export"
    task blacklisted_documents: :environment do
      blacklisted_content_stats = DataExport::ContentExport.new.blacklisted_content_stats
      File.open('tmp/blacklisted_content_stats.json', 'w') do |f|
        f << JSON.dump(blacklisted_content_stats)
      end
    end
  end
end
