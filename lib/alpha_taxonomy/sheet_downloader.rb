module AlphaTaxonomy
  class SheetDownloader
    # This class downloads taxonomy data from a specified set of spreadsheets.
    # It assumes the following about each sheet it imports:
    # a) it is stored on Google drive.
    # b) it is 'published' as a single sheet (not the entire document/workbook),
    #    with tab-seperated values.
    # c) an environment variable called TAXON_SHEETS, containing the name, key
    #    and gid (in that order) is specified at the point this class is used by
    #    any client code.

    # Example credentials set in environment variable:
    # TAXON_SHEETS=early_years,1zjRy7XKrcroscX4cEqc4gM9Eq0DuVWEm_5wATsolRJY,1025053831

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
    end

    def each_sheet
      sheet_credential_tuples.each do |sheet_credentials|
        yield remote_taxonomy_data(sheet_credentials)
      end
    end

    def sheet_credential_tuples
      environment_values = ENV.fetch("TAXON_SHEETS")
      environment_values = environment_values.split(',')
      if environment_values.count % 3 != 0
        raise ArgumentError, "TAXON_SHEETS should be a sequence of three comma-separated values, like so: name1,key1,gid1,name2,key2,gid2"
      end

      environment_values.each_slice(3).map do |triplet|
        { name: triplet[0], key: triplet[1], gid: triplet[2] }
      end
    end

  private

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
  end
end
