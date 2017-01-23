namespace :taxonomy do
  task show_orphans: :environment do
    orphaned_taxons.each do |taxon|
      puts "#{taxon.base_path} (#{taxon.content_id})"
    end
  end

  task remove_orphans: :environment do
    content_ids_to_remove = orphaned_taxons.map(&:content_id)

    content_ids_to_remove.each do |content_id|
      puts "Removing #{content_id}"
      Services.publishing_api.unpublish(content_id, type: 'gone')
    end
  end
end

def orphaned_taxons
  Enumerator.new do |yielder|
    1.step do |page|
      results = RemoteTaxons.new.search(page: page).taxons

      break if results.empty?

      results.each do |result|
        yielder << result unless taxonomy_includes?(result.content_id)
      end
    end
  end
end

def connected_taxonomy
  @taxonomy ||= begin
    root_taxon = ENV['ROOT_TAXON_CONTENT_ID']

    throw "Missing ROOT_TAXON_CONTENT_ID environment variable" if root_taxon.nil?

    Taxonomy::ExpandedTaxonomy.new(root_taxon).build_child_expansion.child_expansion
  end
end

def taxonomy_includes?(content_id, taxonomy: connected_taxonomy)
  return true if taxonomy.content_item.content_id == content_id

  taxonomy.children.any? do |node|
    taxonomy_includes?(content_id, taxonomy: node)
  end
end
