require "gds_api/test_helpers/search"

RSpec.describe "govuk:export_mainstream_taxons", type: :task do
  include RakeTaskHelper
  include ::GdsApi::TestHelpers::Search

  before do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
                                                      "primary_publishing_organisation" => "department-for-transport",
                                                      "organisations" => [{
                                                        "slug" => "department-for-transport",
                                                      }] }] }.to_json)
  end

  it "creates a file" do
    stub_request(:get, "https://content-store.test.gov.uk/content")
     .to_return(status: 200, body: "{}", headers: {})

    FakeFS do
      FileUtils.mkdir_p("tmp")
      expect { rake("govuk:export_mainstream_taxons", "department-for-transport") }
        .to output.to_stdout
      expect(open("tmp/mainstream.csv").read.length).to be > 0
    end
  end
end
