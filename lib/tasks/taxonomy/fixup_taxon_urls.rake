namespace :taxonomy do
  desc "fixup taxon URLs"
  task fixup_taxon_urls: :environment do
    total = RemoteTaxons.new.search.search_response["total"]
    taxon_ids = RemoteTaxons.new.search(per_page: total).taxons.map(&:content_id)

    errors = []

    taxon_ids.each do |taxon_id|
      taxon = Taxonomy::BuildTaxon.call(content_id: taxon_id)

      if !taxon.path_prefix.blank? && !taxon.path_slug.blank?
        if taxon.path_prefix != '/alpha-taxonomy'
          puts "Skipping #{taxon.title} with path #{taxon.path_prefix + taxon.path_slug}"
          next
        end
      end

      puts "Updating #{taxon.title}'s base path"

      slug = '/' + taxon.title.parameterize
      # If the slug is the same as the path prefix, this is the top-level taxon
      taxon.base_path = slug == Theme::EDUCATION_THEME_BASE_PATH ? slug : Theme::EDUCATION_THEME_BASE_PATH + slug

      begin
        Taxonomy::PublishTaxon.call(taxon: taxon)
      rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
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
