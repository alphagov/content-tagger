require 'csv'

namespace :taxonomy do
  namespace :parenting_and_childcare do
    desc "Create top level theme and upload taxons from a remote CSV file (title, description and parent)"
    task :upload_taxons, [:path] => [:environment] do |_, args|
      puts "Creating the top level theme..."
      theme = ParentingChildcare::BuildTheme.build
      taxons_by_title = {}
      taxons_by_title[theme.title] = theme

      puts "Read taxonomy data (taxon title, description and parent)..."
      raw_data = open(args[:path])
      rows = CSV.parse(raw_data, col_sep: "\t", headers: true)

      puts "Creating all taxons..."
      rows.each do |row|
        taxon = ParentingChildcare::BuildTaxon.build(
          title: row['taxon'],
          description: row['description'],
          prefix: theme.base_path
        )

        taxons_by_title[taxon.title] = taxon
      end

      puts "Updating taxons with parents..."
      rows.each do |row|
        parent_title = row['parent_taxon']
        taxon = taxons_by_title[row['taxon']]

        if parent_title.nil?
          puts " => No parent found for '#{taxon.title}, skipping..."
          next
        end

        puts " => Updating '#{taxon.title}' with '#{parent_title}'"
        parent_base_path = taxons_by_title[parent_title].base_path
        content_id = Services.publishing_api.lookup_content_id(base_path: parent_base_path)

        taxon.parent_taxons << content_id
        Taxonomy::PublishTaxon.call(taxon: taxon)
      end
    end
  end
end
