require "csv"
require "net/http"

class RemoteCsv
  class ParsingError < StandardError
    def initialize(error)
      super("#{error.class}: #{error.message}")
    end
  end

  def initialize(csv_url)
    @csv_url = csv_url
  end

  def rows_with_headers
    parsed_data.map(&:to_h)
  rescue StandardError => e
    raise ParsingError, e
  end

private

  def parsed_data
    CSV.parse(sheet_data, headers: true)
  end

  def sheet_data
    response.body
  end

  def response
    Net::HTTP.get_response(URI(@csv_url))
  end
end
