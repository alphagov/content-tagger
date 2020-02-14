require "rake"
require "rails_helper"
require "gds_api/test_helpers/publishing_api_v2"
require "gds_api/test_helpers/search"

RSpec.describe "eu_exit_business_finder:retag_documents_to_facet_values" do
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Search
  include PublishingApiHelper

  let(:publishing_api) { Services.publishing_api }

  let(:facet_values_to_replace) do
    [
      {
        "old_facet_value": "old-facet-value",
        "new_facet_value": "new-facet-value",
      },
    ]
  end

  let(:content_to_update_facet_values) do
    [
      {
        "base_paths": [
          "/guidance/some-document-about-brexit",
        ],
        "old_facet_value": "old-facet-value",
        "new_facet_value": "new-facet-value",
      },
    ]
  end

  let(:facet_values_to_untag) do
    %w[
      another-facet-value
    ]
  end

  let(:search_by_facet_value) do
    {
      "results": [
        {
          "link": "/a-document-about-brexit",
        },
      ],
    }
  end

  let(:search_by_link) do
    {
      "raw_source":
        {
          "content_id": "content-id-to-update",
        },
    }
  end

  let(:content_item_links) do
    {
      "links":
      {
        "facet_values" =>
          %w[
            some-facet-value
            old-facet-value
            another-facet-value
          ],
      },
    }
  end

  let(:updated_content_item_links) do
    {
      "facet_values" =>
        %w[
          some-facet-value
          another-facet-value
          new-facet-value
        ],
    }
  end

  let(:deleted_content_item_links) do
    {
      "facet_values" =>
        %w[
          some-facet-value
          old-facet-value
        ],
    }
  end

  let(:content_id_from_base_path) do
    {
      "/guidance/some-document-about-brexit": "content-id-to-update",
    }
  end

  before :each do
    allow(EuExitBusinessRakeMethods).to receive(:facet_values_to_replace).and_return(facet_values_to_replace)
    allow(EuExitBusinessRakeMethods).to receive(:content_to_update_facet_values).and_return(content_to_update_facet_values)
    allow(EuExitBusinessRakeMethods).to receive(:facet_values_to_untag).and_return(facet_values_to_untag)
    allow(publishing_api).to receive(:patch_links)

    stub_request(:get, "#{Plek.find('search')}/search.json?count=100&filter_facet_values=old-facet-value&start=0")
         .to_return(status: 200, body: search_by_facet_value.to_json, headers: {})
    stub_request(:get, "#{Plek.find('search')}/content?link=/a-document-about-brexit")
         .to_return(status: 200, body: search_by_link.to_json, headers: {})
    stub_request(:get, "#{Plek.find('publishing-api')}/v2/links/content-id-to-update")
         .to_return(status: 200, body: content_item_links.to_json, headers: {})
    stub_request(:post, "#{Plek.find('publishing-api')}/lookup-by-base-path")
         .with(body: "{\"base_paths\":[\"/guidance/some-document-about-brexit\"]}")
         .to_return(status: 200, body: content_id_from_base_path.to_json, headers: {})
    stub_request(:get, "#{Plek.find('search')}/search.json?count=100&filter_facet_values=another-facet-value&start=0")
         .to_return(status: 200, body: search_by_facet_value.to_json, headers: {})
  end

  it "updates relevant content items" do
    Rake::Task["eu_exit_business_finder:retag_documents_to_facet_values"].invoke
    expect(publishing_api).to have_received(:patch_links).with("content-id-to-update", links: updated_content_item_links).exactly(2).times
    expect(publishing_api).to have_received(:patch_links).with("content-id-to-update", links: deleted_content_item_links)
  end
end
