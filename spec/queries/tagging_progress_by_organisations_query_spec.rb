require 'rails_helper'

RSpec.describe TaggingProgressByOrganisationsQuery do
  describe "#percentage_tagged_and_done" do
    it "calculates progress for a list of organisations" do
      stub_request(:get, rummager_url_for_all_document_counts)
        .to_return(body: all_document_counts_response.to_json)

      stub_request(:get, rummager_url_for_tagged_document_counts)
        .to_return(body: tagged_documents_counts_response.to_json)

      expect(
        described_class.new(
          [
            "department-for-transport",
            "high-speed-two-limited",
            "home-office",
            "maritime-and-coastguard-agency",
          ]
        ).percentage_tagged
      ).to eq(
        "department-for-transport" => 18.34360027378508,
        "high-speed-two-limited" => 98.80478087649402,
        "home-office" => 0.0,
        "maritime-and-coastguard-agency" => 57.265692175408425,
      )
    end

    it "returns an empty hash when the responses are empty" do
      stub_request(:get, rummager_url_for_all_document_counts)
        .to_return(body: {}.to_json)

      stub_request(:get, rummager_url_for_tagged_document_counts)
        .to_return(body: {}.to_json)

      expect(
        described_class.new(
          [
            "department-for-transport",
            "high-speed-two-limited",
            "home-office",
            "maritime-and-coastguard-agency",
          ]
        ).percentage_tagged
      ).to eq({})
    end
  end

  def rummager_url_for_all_document_counts
    "https://rummager.test.gov.uk/search.json?aggregate_primary_publishing_organisation=0,scope:all_filters&count=0&filter_primary_publishing_organisation%5B%5D=department-for-transport&filter_primary_publishing_organisation%5B%5D=high-speed-two-limited&filter_primary_publishing_organisation%5B%5D=home-office&filter_primary_publishing_organisation%5B%5D=maritime-and-coastguard-agency&start=0"
  end

  def all_document_counts_response
    {
      "results" => [],
      "total" => 15_235,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "home-office" }, "documents" => 7475 },
            { "value" => { "slug" => "department-for-transport" }, "documents" => 5844 },
            { "value" => { "slug" => "maritime-and-coastguard-agency" }, "documents" => 1163 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 753 }
          ],
          "documents_with_no_value" => 0,
          "total_options" => 4,
          "missing_options" => 4,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => []
    }
  end

  def rummager_url_for_tagged_document_counts
    "https://rummager.test.gov.uk/search.json?aggregate_primary_publishing_organisation=0,scope:all_filters&count=0&filter_primary_publishing_organisation%5B%5D=department-for-transport&filter_primary_publishing_organisation%5B%5D=high-speed-two-limited&filter_primary_publishing_organisation%5B%5D=home-office&filter_primary_publishing_organisation%5B%5D=maritime-and-coastguard-agency&reject_taxons=_MISSING&start=0"
  end

  def tagged_documents_counts_response
    {
      "results" => [],
      "total" => 2490,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "home-office" }, "documents" => 0 },
            { "value" => { "slug" => "department-for-transport" }, "documents" => 1072 },
            { "value" => { "slug" => "maritime-and-coastguard-agency" }, "documents" => 666 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 744 }
          ],
          "documents_with_no_value" => 0,
          "total_options" => 4,
          "missing_options" => 4,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => []
    }
  end
end
