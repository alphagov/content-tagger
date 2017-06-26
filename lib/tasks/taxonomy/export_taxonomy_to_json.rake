require 'json'

namespace :taxonomy do
  desc <<-DESC
    Exports an expanded taxonomy to a single JSON array
  DESC
  namespace :export do
    task :json, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)
      root_taxon = OpenStruct.new(Services.publishing_api.get_content(root_taxon_id).to_h)
      taxonomy = Taxonomy::ExpandedTaxonomy.new(root_taxon.content_id)
      taxonomy.build

      flattened_taxonomy = flatten_taxonomy(taxonomy.child_expansion)

      puts JSON.generate(flattened_taxonomy)
    end

    def flatten_taxonomy(taxon)
      flattened_taxonomy = [convert_to_content_item(taxon)]

      if taxon.children
        taxon.children.each do |child_taxon|
          flattened_taxonomy += flatten_taxonomy(child_taxon)
        end
      end

      flattened_taxonomy
    end

    def convert_to_content_item(taxon, recursion_direction = nil)
      taxon_content = OpenStruct.new(Services.publishing_api.get_content(taxon.content_id).to_h)

      content_item = {
        base_path: taxon.base_path,
        content_id: taxon.content_id,
        title: taxon.title,
        description: taxon_content.description,
        document_type: 'taxon',
        publishing_app: 'content-tagger',
        rendering_app: 'collections',
        schema_name: 'taxon',
        user_journey_document_supertype: 'finding',
        links: {},
      }

      unless recursion_direction == :parent
        content_item[:links][:child_taxons] = taxon.children.map { |child| convert_to_content_item(child, :child) }
      end
      unless recursion_direction == :child
        if taxon.parent
          content_item[:links][:parent_taxons] = [convert_to_content_item(taxon.parent, :parent)]
        end
      end

      content_item
    end
  end
end
