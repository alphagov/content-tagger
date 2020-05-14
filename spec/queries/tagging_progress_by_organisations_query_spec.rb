require "rails_helper"

RSpec.describe TaggingProgressByOrganisationsQuery do
  include TaxonomyHelper

  before do
    stub_draft_taxonomy_branch
  end

  let(:name) do
    %w[department-for-transport high-speed-two-limited]
  end

  describe "#percentage_tagged" do
    it "returns an empty table when nothing is returned" do
      stub_search_api_totals(search_api_empty)
      stub_search_api_tagged(search_api_empty)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged).to be_empty
    end

    it "returns zeros when there are no documents" do
      stub_search_api_totals(search_api_zeros)
      stub_search_api_tagged(search_api_zeros)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged)
        .to eq(
          "department-for-transport" => { percentage: 0.0, total: 0, tagged: 0 },
          "high-speed-two-limited" => { percentage: 0.0, total: 0, tagged: 0 },
        )
    end

    it "returns correct values" do
      stub_search_api_totals(search_api_totals)
      stub_search_api_tagged(search_api_tagged)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged)
        .to eq(
          "department-for-transport" => { percentage: 25.0, total: 20, tagged: 5 },
          "high-speed-two-limited" => { percentage: 56.25, total: 80, tagged: 45 },
        )
    end
  end

  describe "#total_counts" do
    it "returns an empty hash when nothing is returned" do
      stub_search_api_totals(search_api_empty)
      stub_search_api_tagged(search_api_empty)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).total_counts).to be_empty
    end

    it "returns zeros when there are no documents" do
      stub_search_api_totals(search_api_zeros)
      stub_search_api_tagged(search_api_zeros)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).total_counts).to eq(percentage: 0.0, total: 0, tagged: 0)
    end

    it "returns correct totals" do
      stub_search_api_totals(search_api_totals)
      stub_search_api_tagged(search_api_tagged)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).total_counts)
        .to eq(percentage: 50.0, total: 100, tagged: 50)
    end
  end

  # HELPERS #
  def stub_search_api_tagged(return_hash)
    allow(Services.search_api).to receive(:search).with(
      hash_including(filter_part_of_taxonomy_tree: anything),
    ).and_return return_hash
  end

  def stub_search_api_totals(return_hash)
    allow(Services.search_api).to receive(:search).with(
      hash_excluding(filter_part_of_taxonomy_tree: anything),
    ).and_return return_hash
  end

  def organisations
    %w[department-for-transport high-speed-two-limited]
  end

  def search_api_empty
    { "results" => [],
      "total" => 100,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [],
          "documents_with_no_value" => 80,
          "total_options" => 10,
          "missing_options" => 10,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [] }
  end

  def search_api_totals
    { "results" => [],
      "total" => 100,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 20 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 80 },
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [] }
  end

  def search_api_tagged
    { "results" => [],
      "total" => 50,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 5 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 45 },
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [] }
  end

  def search_api_zeros
    { "results" => [],
      "total" => 50,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 0 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 0 },
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [] }
  end
end
