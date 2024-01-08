require "csv"

module BulkTagging
  class FetchRemoteData
    attr_reader :tagging_spreadsheet
    attr_accessor :errors

    def self.call(tagging_spreadsheet)
      new(tagging_spreadsheet).call
    end

    def initialize(tagging_spreadsheet)
      @tagging_spreadsheet = tagging_spreadsheet
      @errors = []
    end

    def call
      response
      process_spreadsheet
      errors
    rescue StandardError => e
      GovukError.notify(e)
      [spreadsheet_download_error]
    end

  private

    def process_spreadsheet
      parsed_data.each do |row|
        save_row(row)
      end
    rescue StandardError => e
      errors << e
    end

    def save_row(row)
      TagMapping.create!(
        tagging_source: tagging_spreadsheet,
        content_base_path: cast_and_strip(row["content_base_path"]),
        link_title: cast_and_strip(row["link_title"]),
        link_content_id: cast_and_strip(row["link_content_id"]),
        link_type: "taxons",
        state: "ready_to_tag",
      )
    end

    def cast_and_strip(string)
      String(string).strip
    end

    def parsed_data
      CSV.parse(sheet_data, headers: true)
    end

    def spreadsheet_download_error
      I18n.t("errors.spreadsheet_download_error")
    end

    def response
      separate = HTTParty.get tagging_spreadsheet.url
      if separate.code == 200
        @response = separate
      else
        raise StandardError, "error code from httparty"
      end
    end

    def sheet_data
      response.body
    end
  end
end
