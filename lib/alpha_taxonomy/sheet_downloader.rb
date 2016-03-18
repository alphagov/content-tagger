module AlphaTaxonomy
  class SheetDownloader
    attr_reader :sheet_identifier_tuples

    def initialize(logger: Logger.new(STDOUT), sheet_identifiers:)
      @log = logger
      if sheet_identifiers.count % 3 != 0
        raise ArgumentError, sheet_identifiers_error_message
      end
      @sheet_identifier_tuples = parse_identifiers(sheet_identifiers)
    end

    def each_sheet
      @sheet_identifier_tuples.each do |sheet_identifiers|
        yield remote_taxonomy_data(sheet_identifiers)
      end
    end

  private

    def parse_identifiers(sheet_identifiers)
      sheet_identifiers.each_slice(3).map do |triplet|
        { name: triplet[0], key: triplet[1], gid: triplet[2] }
      end
    end

    def remote_taxonomy_data(sheet_info)
      sheet_url = spreadsheet_url(key: sheet_info[:key], gid: sheet_info[:gid])
      @log.info "Attempting download of #{sheet_info[:name]} (#{sheet_url})"
      remote_taxonomy_data = Net::HTTP.get URI(sheet_url)
      @log.info "Downloaded #{sheet_info[:name]}"
      remote_taxonomy_data
    end

    def spreadsheet_url(key:, gid:)
      "https://docs.google.com/spreadsheets/d/#{key}/pub?gid=#{gid}&single=true&output=tsv"
    end

    def sheet_identifiers_error_message
      "sheet_identifiers should be a sequence of three comma-separated values, like so: ['name1','key1','gid1','name2','key2','gid2']"
    end
  end
end
