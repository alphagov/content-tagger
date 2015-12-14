require "csv"

module AlphaTaxonomy
  class SheetParser
    class BlankMappingField < StandardError; end

    def initialize(taxonomy_data_stream)
      @taxonomy_data_stream = taxonomy_data_stream
    end

    def write_to(file)
      relevant_columns_in(@taxonomy_data_stream).each do |row|
        mapped_to = row[0]
        link = row[1]

        if mapped_to.blank? || link.blank?
          raise BlankMappingField, "Missing value in taxonomy spreadsheet"
        end

        if mapped_to[0..2] == "n/a"
          next
        else
          taxon_titles = stripped_array_of(mapped_to)
          taxon_titles.each do |taxon_title|
            file.write("#{taxon_title}\t#{link}\n")
          end
        end
      end
    end

  private

    def relevant_columns_in(taxonomy_data_stream)
      tsv_data = CSV.parse(taxonomy_data_stream, col_sep: "\t", headers: true)
      desired_columns = ["mapped to", "link"]
      columns_in_data = tsv_data.headers.map(&:downcase)

      if desired_columns.all? { |column_name| columns_in_data.include? column_name }
        tsv_data.values_at(*desired_columns)
      else
        raise ArgumentError, "Column names did not match expected values #{desired_columns}"
      end
    end

    # We expect taxonomy_labels to be a pipe-separated list.
    # Return an array of whitespace-stripped taxon titles.
    def stripped_array_of(taxon_titles)
      taxon_titles.split('|').map(&:strip)
    end
  end
end
