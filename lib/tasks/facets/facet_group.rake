require "facet_group_importer"

namespace :facets do
  desc <<-DESC
    Imports a facet group defined in a YAML file located at `facet_group_file_path`.
    This creates the relevant facet_group, facets and facet_values content items
    as drafts in the Publishing API. It also links these content items to reflect the
    shallow tree structure of a facet group.
  DESC
  task :import_facet_group, [:facet_group_file_path] => :environment do |_, args|
    FacetGroupImporter.new(args[:facet_group_file_path]).import
  end
end
