namespace :taxonomy do
  desc "fixup taxon URLs"
  task fixup_taxon_urls: :environment do
    total = RemoteTaxons.new.search.search_response["total"]
    taxon_ids = RemoteTaxons.new.search(per_page: total).taxons.map(&:content_id)

    errors = []

    taxon_ids.each do |taxon_id|
      taxon = Taxonomy::BuildTaxon.call(content_id: taxon_id)

      puts "Updating #{taxon.title}'s base path"

      EducationTaxonNamer.rename_taxon(taxon)

      puts "\t-> #{taxon.title}"

      begin
        Taxonomy::PublishTaxon.call(taxon: taxon, validate: false)
      rescue => e
        puts "#{taxon.title} is invalid"
        puts e.cause
        errors.push(taxon_base_path: taxon.base_path, taxon_id: taxon.content_id, e: e)
      end
    end

    puts "Finished with #{errors.length} errors"

    unless errors.empty?
      puts "The following taxons could not be updated:"
      errors.each do |error|
        puts "#{error[:taxon_id]} #{error[:taxon_base_path]}"
      end
    end
  end
end
