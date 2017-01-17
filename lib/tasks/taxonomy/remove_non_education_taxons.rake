namespace :taxonomy do
  desc "remove non-education taxons"
  task remove_non_education_taxons: :environment do
    all_taxon_ids = fetch_all_taxon_ids
    education_taxon_ids = fetch_education_taxon_ids

    puts "Find non-education taxon IDs"
    non_education_taxon_ids = all_taxon_ids - education_taxon_ids

    errors = []

    non_education_taxon_ids.each do |taxon_id|
      taxon = Taxonomy::BuildTaxon.call(content_id: taxon_id)
      puts "Removing: #{taxon.content_id} #{taxon.title}"
      begin
        Services.publishing_api.unpublish(taxon_id, type: "gone").code
      rescue GdsApi::HTTPUnprocessableEntity => e
        puts e.message
        errors << { taxon_id: taxon.content_id, taxon_title: taxon.title }
      end
    end

    puts "Finished with #{errors.length} errors."

    puts "The following taxons could not be unpublished:" unless errors.empty?

    errors.each do |error|
      puts "#{error[:taxon_id]} #{error[:taxon_title]}"
    end
  end

  def fetch_all_taxon_ids
    puts "Fetch all taxon IDs"
    total = RemoteTaxons.new.search.search_response["total"]
    RemoteTaxons.new.search(per_page: total).taxons.map(&:content_id)
  end

  def fetch_education_taxon_ids
    puts "Fetch education taxon IDs"
    taxon_id = 'c58fdadd-7743-46d6-9629-90bb3ccc4ef0'

    chosen_taxon = OpenStruct.new Services.publishing_api.get_content(taxon_id).to_h
    taxonomy = Taxonomy::ExpandedTaxonomy.new(chosen_taxon.content_id)
    taxonomy.build_child_expansion

    taxonomy.child_expansion.map(&:content_id)
  end
end
