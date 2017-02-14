require 'csv'

namespace :taxonomy do
  desc <<-DESC
    Download content base paths from the taxonomy. Provide the content ID of a
    taxon as a starting point. The script will print to STDOUT base paths for
    all content tagged to the chosen taxon and all of its children.
  DESC
  task :export_tagged_content, [:taxon_id] => :environment do |_, args|
    taxon_id = args.fetch(:taxon_id)
    output = {}

    chosen_taxon = OpenStruct.new Services.publishing_api.get_content(taxon_id).to_h
    taxonomy = Taxonomy::ExpandedTaxonomy.new(chosen_taxon.content_id)
    taxonomy.build_child_expansion

    taxons = taxonomy.child_expansion.map do |node|
      { base_path: node.content_item.base_path, content_id: node.content_id }
    end

    taxons.each do |taxon|
      linked_items = Services.publishing_api.get_linked_items(
        taxon[:content_id],
        link_type: "taxons",
        fields: %w(base_path)
      ).to_a
      taxon_content = linked_items.map { |item| item.fetch("base_path") }
      output[taxon[:base_path]] = taxon_content
    end

    rows = ["Link,TaxonPath"]
    output.each do |taxon_path, content_paths|
      content_paths.each do |content_path|
        rows << "#{content_path},#{taxon_path}"
      end
    end

    puts rows
  end
end
