module AlphaTaxonomy
  class SheetDownloader
    # This class downloads taxonomy data from a specified set of spreadsheets.
    # It assumes the following about each sheet it imports:
    # a) it is stored on Google drive.
    # b) it is 'published' as a single sheet (not the entire document/workbook),
    #    with tab-seperated values.
    # c) its key and gid are populated in the sheets class attribute.

    # TODO: change this so that sheets can be specified as an ENV variable - saves
    # us having to deploy in order to support additional sheets.
    class_attribute :sheets
    self.sheets = [
      { name: "early_years", key: "1zjRy7XKrcroscX4cEqc4gM9Eq0DuVWEm_5wATsolRJY", gid: "1025053831" },
      { name: "curriculum_content_mapping", key: "1rViQioxz5iu3hGYFldNOJift0PqjX0fYd8LZz07ljd4", gid: "678558707" },
      { name: "driving", key: "19GhkAQ9VEmsiPeoHbrz9Q-nTnbtLxC2kkD6szoGGam0", gid: "1102496302" },
    ]

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
    end

    def each_sheet
      self.class.sheets.each do |sheet_credentials|
        yield remote_taxonomy_data(sheet_credentials)
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
