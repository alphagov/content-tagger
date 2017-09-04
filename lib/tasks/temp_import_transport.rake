task temp_import_transport: :environment do
  data = JSON.parse(File.read('lib/tasks/temp_import_transport.json'))

  Theme.find_or_create_by(name: 'Transport', path_prefix: '/transport')

  # Create the root taxon first
  taxon = Taxon.new(
    title: data.fetch('name'),
    internal_name: data.fetch('name'),
    description: '...',
    parent: [], # this is the root
    content_id: data.fetch('content_id'),
    base_path: data.fetch('base_path'),
  )

  Taxonomy::UpdateTaxon.call(taxon: taxon)

  recursively_create_child_taxons(data, data["child_taxons"])
end

def recursively_create_child_taxons(parent, child_taxons)
  child_taxons.each do |child|
    taxon = Taxon.new(
      title: child.fetch('name'),
      internal_name: child.fetch('name'),
      description: '...',
      parent: parent.fetch('content_id'),
      content_id: child.fetch('content_id'),
      base_path: child.fetch('base_path'),
    )

    Taxonomy::UpdateTaxon.call(taxon: taxon)
    recursively_create_child_taxons(child, child["child_taxons"])
  end
end
