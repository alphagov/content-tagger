desc "Populate legacy_taxons links for each topic taxon according to a CSV"
task :load_legacy_mappings, [:csv_path] => :environment do |_t, args|
  mapping = {}

  CSV.foreach(args[:csv_path]) do |row|
    mapping[row[0]] = row[1].split("|")
  end

  api = Services.publishing_api
  api.client.options[:timeout] = 30

  mapping.each do |topic_taxon_id, legacy_taxons|
    begin
      legacy_taxon_ids = api.lookup_content_ids(base_paths: legacy_taxons)
      missing_legacy_taxons = legacy_taxons - legacy_taxon_ids.keys
      raise "Lookup failed for #{missing_legacy_taxons}" if missing_legacy_taxons.any?

      puts "Adding #{legacy_taxons.count} legacy taxons for #{topic_taxon_id}"
      api.patch_links(topic_taxon_id,
                      links: { legacy_taxons: legacy_taxon_ids.values },
                      bulk_publishing: true)
    rescue StandardError => e
      warn "Failed to patch #{topic_taxon_id}: #{e.message}"
    end
  end
end
