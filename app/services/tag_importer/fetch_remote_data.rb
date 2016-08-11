require 'csv'

module TagImporter
  class FetchRemoteData
    attr_reader :tagging_spreadsheet
    attr_accessor :errors

    def initialize(tagging_spreadsheet)
      @tagging_spreadsheet = tagging_spreadsheet
      @errors = []
    end

    def run
      unless valid_response?
        Airbrake.notify(RuntimeError.new(response.body))
        return [spreadsheet_download_error]
      end

      process_spreadsheet
      errors
    end

  private

    def process_spreadsheet
      parsed_data.each do |row|
        save_row(row)
      end
    rescue => e
      errors << e
    end

    def save_row(row)
      tagging_spreadsheet.tag_mappings.build(
        content_base_path:  row["content_base_path"],
        link_title:         row["link_title"],
        link_content_id:    row["link_content_id"],
        link_type:          row["link_type"],
      ).save
    end

    def parsed_data
      CSV.parse(sheet_data, col_sep: "\t", headers: true)
    end

    def spreadsheet_download_error
      I18n.t('errors.spreadsheet_download_error')
    end

    def valid_response?
      response.code == '200'
    end

    def response
      @response ||= Net::HTTP.get_response(URI(tagging_spreadsheet.url))
    end

    def sheet_data
      response.body
    end
  end
end
