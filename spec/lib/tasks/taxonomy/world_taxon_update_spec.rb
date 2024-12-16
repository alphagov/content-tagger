require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/publishing_api"

RSpec.describe "worldwide:add_country_name_to_title" do
  include RakeTaskHelper
  include PublishingApiHelper

  it "updates the title of worldwide taxons to include the name of the country they relate to" do
    # Given a worldwide taxon with a title that does not include the name of the country it relates to
    parent_taxon = FactoryBot.build(:taxon, base_path: "/world/all")
    allow(Taxonomy::BuildTaxon).to receive(:call).and_return(parent_taxon)

    worldwide_taxon = FactoryBot.build(
      :taxon,
      base_path: "/world/trade-and-invest-japan",
      internal_name: "Trade and invest (Japan)",
      parent_content_id: parent_taxon.content_id,
      title: "Trade and invest",
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/f186bbc9-09c8-4848-897d-f77dadb693fb")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer example",
          "Host" => "publishing-api.test.gov.uk",
          "User-Agent" => "gds-api-adapters/97.1.0 ()",
        },
      )
      .to_return(status: 200, body: {
        "content_id" => parent_taxon.content_id,
        "title" => worldwide_taxon.title,
        "base_path" => worldwide_taxon.base_path,
      }.to_json)

    # When the task is invoked
    rake "worldwide:add_country_name_to_title"

    # Then the title of the worldwide taxon should be updated to include the name of the country it relates to
    expect(worldwide_taxon.reload.title).to eq("Trade and invest in Japan")
  end
end
