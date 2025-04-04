RSpec.describe RemoteCsv do
  describe "#rows_with_headers" do
    let(:csv_url) { "http://example.com/sheet.csv" }

    it "returns an array of hashes" do
      stub_request(:get, csv_url).to_return(body: <<~CSV.delete(" "))
        url,     title,     description
        url_one, title_one, description_one
        url_two, title_two, description_two
      CSV

      expect(described_class.new(csv_url).rows_with_headers).to eq [
        {
          "url" => "url_one",
          "title" => "title_one",
          "description" => "description_one",
        },
        {
          "url" => "url_two",
          "title" => "title_two",
          "description" => "description_two",
        },
      ]
    end

    it "raises an error when the URI is invalid" do
      expect { described_class.new("not a URL").rows_with_headers }
        .to raise_error RemoteCsv::ParsingError, 'URI::InvalidURIError: bad URI (is not URI?): "not a URL"'
    end

    it "raises an error when the connection failed" do
      stub_request(:get, csv_url).to_timeout

      expect { described_class.new(csv_url).rows_with_headers }
        .to raise_error RemoteCsv::ParsingError, "Net::OpenTimeout: execution expired"
    end

    it "raises an error when the CSV is malformed" do
      stub_request(:get, csv_url).to_return(body: "1,\"23\"4\"5\", 6")

      expect { described_class.new(csv_url).rows_with_headers }
        .to raise_error RemoteCsv::ParsingError, "CSV::MalformedCSVError: Any value after quoted field isn't allowed in line 1."
    end
  end
end
