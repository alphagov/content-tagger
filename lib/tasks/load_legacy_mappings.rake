desc "Populate legacy_taxons links for each topic taxon according to a CSV"
task :load_legacy_mappings, [:csv_path] => :environment do |_t, args|
  mapping = Hash.new { |h, k| h[k] = [] }

  CSV.foreach(args[:csv_path]) do |row|
    mapping[row[1]] << row[0].match(/.+\[(.+)\]/)[1]
  end

  api = Services.publishing_api
  api.client.options[:timeout] = 30

  mapping.each do |topic_taxon, legacy_taxons|
    begin
      topic_taxon_id = api.lookup_content_id(base_path: topic_taxon)
      raise "Lookup failed for #{topic_taxon}" unless topic_taxon_id
      topic_taxon_links = api.get_links(topic_taxon_id)["links"]

      legacy_taxon_ids = api.lookup_content_ids(base_paths: legacy_taxons)
      missing_legacy_taxons = legacy_taxons - legacy_taxon_ids.keys
      raise "Lookup failed for #{missing_legacy_taxons}" if missing_legacy_taxons.any?
      topic_taxon_links["legacy_taxons"] = legacy_taxon_ids.values

      puts "Adding #{legacy_taxons.count} legacy taxons for #{topic_taxon}"
      api.patch_links(topic_taxon_id, links: topic_taxon_links, bulk_publishing: true)
    rescue StandardError => e
      puts "Failed to patch #{topic_taxon}: #{e.message}"
    end
  end
end
