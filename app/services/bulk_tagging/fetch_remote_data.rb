require 'csv'

module BulkTagging
  class FetchRemoteData
    attr_reader :tagging_spreadsheet

    def initialize(tagging_spreadsheet)
      @tagging_spreadsheet = tagging_spreadsheet
    end

    def run
      errors = []
      begin
        parsed_data = CSV.parse(sheet_data, col_sep: "\t", headers: true)
        parsed_data.each do |row|
          tagging_spreadsheet.tag_mappings.build(
            content_base_path:  row["content_base_path"],
            link_title:         row["link_title"],
            link_content_id:    row["link_content_id"],
            link_type:          row["link_type"],
          ).save
        end
      rescue => e
        errors << e
      end
      errors
    end

  private

    def sheet_data
      @sheet_data ||= Net::HTTP.get URI(tagging_spreadsheet.url)
    end
  end
end
