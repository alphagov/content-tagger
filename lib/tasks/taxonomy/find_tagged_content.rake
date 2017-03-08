namespace :taxonomy do
  desc "Find content tagged with the given document type"
  task :find_tagged_content_with_document_type, [:document_type] => :environment do |_t, args|
    output = Set.new

    taxons = RemoteTaxons.new.search(per_page: 10_000).taxons

    taxons.each do |taxon|
      linked_items = Services.publishing_api.get_linked_items(
        taxon.content_id,
        link_type: "taxons",
        fields: %w(base_path document_type)
      ).to_a.select { |item| item.fetch("document_type") == args[:document_type] }

      taxon_content = linked_items.map { |item| item.fetch("base_path") }

      output.merge(taxon_content)
    end

    puts output.to_a
  end
end
