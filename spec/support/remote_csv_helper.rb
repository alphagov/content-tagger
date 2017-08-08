module RemoteCsvHelper
  CSV_URL = 'http://www.example.com/my_csv'.freeze
  CSV_HEADERS = %w(url title description).freeze
  CSV_ROWS = [%w(http://content_one title_one description_one), %w(http://content_two title_two description_two)].freeze
  CSV_CONTENTS = CSV_HEADERS.join(',') + "\n" + CSV_ROWS.map { |row| row.join(',') }.join("\n")

  def stub_remote_csv
    stub_request(:get, CSV_URL).to_return(body: CSV_CONTENTS)
  end
end
