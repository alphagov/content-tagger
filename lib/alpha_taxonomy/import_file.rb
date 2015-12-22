require "csv"

module AlphaTaxonomy
  class ImportFile
    class BlankMappingFieldError < StandardError; end

    class_attribute :location
    self.location = begin
      return ENV["TAXON_IMPORT_FILE"] if ENV["TAXON_IMPORT_FILE"]
      FileUtils.mkdir_p Rails.root + "lib/data/"
      "#{Rails.root}" + "/lib/data/alpha_taxonomy_import.tsv"
    end

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
      @file = File.new(self.class.location, "wb")
    end

    def populate
      write_headers
      SheetDownloader.new.each_sheet do |taxonomy_data|
        write(taxonomy_data)
      end
      @file.close
    rescue => e
      log_failure(e)
      clean_up
    end

    def clean_up
      File.delete(@file.path) if File.exist?(@file.path)
    end

  private

    def write_headers
      @file.write("taxon_title\tbase_path\n")
    end

    def write(taxonomy_data)
      relevant_columns_in(taxonomy_data).each do |row|
        mapped_to = row[0]
        base_path = row[1]

        if mapped_to.blank? || base_path.blank?
          raise BlankMappingFieldError, "Missing value in downloaded taxonomy spreadsheet"
        end

        if mapped_to[0..2] == "n/a"
          next
        else
          taxon_titles = stripped_array_of(mapped_to)
          taxon_titles.each do |taxon_title|
            @file.write("#{taxon_title}\t#{base_path}\n")
          end
        end
      end
    end

    def relevant_columns_in(taxonomy_data)
      tsv_data = CSV.parse(taxonomy_data, col_sep: "\t", headers: true)
      desired_columns = ["mapped to", "link"]
      columns_in_data = tsv_data.headers.map(&:downcase)

      if desired_columns.all? { |column_name| columns_in_data.include? column_name }
        tsv_data.values_at(*desired_columns)
      else
        raise ArgumentError, "Column names in downloaded taxonomy data did not match expected values: #{desired_columns}"
      end
    end

    def log_failure(exception)
      @log.error "Failed to create import file"
      @log.error "Exception: #{exception}"
      @log.error "#{exception.backtrace.join("\n")}"
    end

    # We expect taxonomy_labels to be a pipe-separated list.
    # Return an array of whitespace-stripped taxon titles.
    def stripped_array_of(taxon_titles)
      taxon_titles.split('|').map(&:strip)
    end
  end
end
