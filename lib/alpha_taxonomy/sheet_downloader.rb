module AlphaTaxonomy
  class SheetDownloader
    # This class downloads taxonomy data from a specified set of spreadsheets.
    # It assumes the following about each sheet it imports:
    # a) it is stored on Google drive.
    # b) it is 'published' as a single sheet (not the entire document/workbook),
    #    with tab-seperated values.
    # c) its key and gid are populated in the SHEETS constant.

    class_attribute :cache_location
    self.cache_location = begin
      return ENV["TAXON_IMPORT_FILE"] if ENV["TAXON_IMPORT_FILE"]
      FileUtils.mkdir_p Rails.root + "lib/data/"
      "#{Rails.root}" + "/lib/data/alpha_taxonomy_import.csv"
    end

    SHEETS = [
      { name: "early_years", key: "1zjRy7XKrcroscX4cEqc4gM9Eq0DuVWEm_5wATsolRJY", gid: "1025053831" },
      { name: "curriculum_content_mapping", key: "1rViQioxz5iu3hGYFldNOJift0PqjX0fYd8LZz07ljd4", gid: "678558707" },
    ]

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
    end

    def download
      make_default_directory
      File.open(self.class.cache_location, "wb") do |file|
        write_headers_to(file)
        SHEETS.each do |sheet_info|
          AlphaTaxonomy::SheetParser.new(remote_taxonomy_data(sheet_info)).write_to(file)
          @log.info "Finished copying #{sheet_info[:name]}"
        end
      end
    rescue => e
      log_failure(e)
      clean_up
    end

    def clean_up
      File.delete self.class.cache_location if File.exist? self.class.cache_location
    end

  private

    def make_default_directory
      FileUtils.mkdir_p Rails.root + "lib/data/"
    end

    def write_headers_to(file)
      file.write("taxon_title\ttaxon_slug\tlink\n")
    end

    def remote_taxonomy_data(sheet_info)
      sheet_url = spreadsheet_url(key: sheet_info[:key], gid: sheet_info[:gid])
      @log.info "Attempting download of #{sheet_info[:name]} (#{sheet_url})"
      remote_taxonomy_data = Net::HTTP.get URI(sheet_url)
      @log.info "Downloaded #{sheet_info[:name]}"
      remote_taxonomy_data
    end

    def log_failure(exception)
      @log.error "Failed to download and merge all taxonomy sheets"
      @log.error "Exception: #{exception}"
      @log.error "#{exception.backtrace.join("\n")}"
    end

    def spreadsheet_url(key:, gid:)
      "https://docs.google.com/spreadsheets/d/#{key}/pub?gid=#{gid}&single=true&output=tsv"
    end
  end
end
