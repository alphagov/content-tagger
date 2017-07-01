module BulkTagging
  class IndexPage
    def spreadsheets
      tagging_spreadsheets.map do |tagging_spreadsheet|
        BulkTagging::TaggingSpreadsheetPresenter.new(tagging_spreadsheet)
      end
    end

    def tagging_spreadsheets
      BulkTagging::TaggingSpreadsheet.active.newest_first.includes(:added_by)
    end
  end
end
