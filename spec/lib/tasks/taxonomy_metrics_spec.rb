require "gds_api/test_helpers/search"

RSpec.describe "metrics:taxonomy", type: :task do
  include RakeTaskHelper
  include ::GdsApi::TestHelpers::Search

  before :each do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }], "total" => 1 }.to_json)
  end

  context "count_content_per_level" do
    it "writes to stdout" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/")
       .to_return(status: 200, body: "{}", headers: {})

      expect {
        rake("metrics:taxonomy:count_content_per_level")
      }.to output(/.+/).to_stdout
    end
  end

  context "record_content_coverage_metrics" do
    it "writes to stdout" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/")
       .to_return(status: 200, body: "{}", headers: {})
      stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a")
       .to_return(status: 200, body: "{}", headers: {})

      expect {
        rake("metrics:taxonomy:record_content_coverage_metrics")
      }.to output(/.+/).to_stdout
    end
  end

  context "record_number_of_superfluous_taggings_metrics" do
    it "writes to stdout" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/")
       .to_return(status: 200, body: "{}", headers: {})

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
       .to_return(status: 200, body: {}.to_json, headers: {})

      expect {
        rake("metrics:taxonomy:record_number_of_superfluous_taggings_metrics")
      }.to output(/.+/).to_stdout
    end
  end
end
