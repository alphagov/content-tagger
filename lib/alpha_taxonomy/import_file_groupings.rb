require 'csv'

module AlphaTaxonomy
  class ImportFileGroupings
    include AlphaTaxonomy::Helpers::ImportFileHelper

    # Return a hash in the following form
    # {
    #   '/content-base-path-1' => [ 'taxon-title-1', 'taxon-title-2' ],
    #   '/content-base-path-2' => [ 'taxon-title-2', 'taxon-title-3' ],
    # }
    def extract
      check_import_file_is_present
      mappings = CSV.read(AlphaTaxonomy::ImportFile.location, col_sep: "\t", headers: true)
      mappings.each_with_object({}) do |row, hash|
        base_path = row["base_path"]
        taxon_title = row["taxon_title"]

        hash[base_path] = [] unless hash[base_path].present?
        hash[base_path] << taxon_title
      end
    end
  end
end
