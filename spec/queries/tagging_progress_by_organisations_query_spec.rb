require 'rails_helper'

RSpec.describe TaggingProgressByOrganisationsQuery do
  let(:name) do
    ['department-for-transport', 'high-speed-two-limited']
  end

  describe '#percentage_tagged' do
    it 'returns an empty table when nothing is returned' do
      stub_rummager_totals(rummager_empty)
      stub_rummager_untagged(rummager_empty)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged).to be_empty
    end

    it 'returns zeros when there are no documents' do
      stub_rummager_totals(rummager_zeros)
      stub_rummager_untagged(rummager_zeros)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged)
        .to eq('department-for-transport' => { percentage: 0.0, total: 0, tagged: 0 },
               'high-speed-two-limited' => { percentage: 0.0, total: 0, tagged: 0 })
    end

    it 'returns correct values' do
      stub_rummager_totals(rummager_totals)
      stub_rummager_untagged(rummager_untagged)
      expect(TaggingProgressByOrganisationsQuery.new(organisations).percentage_tagged)
        .to eq('department-for-transport' => { percentage: 25.0, total: 20, tagged: 5 },
               'high-speed-two-limited' => { percentage: 56.25, total: 80, tagged: 45 })
    end
  end

  # HELPERS #
  def stub_rummager_untagged(return_hash)
    allow(Services.rummager).to receive(:search).with(hash_including(reject_taxons: '_MISSING')).and_return return_hash
  end

  def stub_rummager_totals(return_hash)
    allow(Services.rummager).to receive(:search).with(hash_excluding(reject_taxons: '_MISSING')).and_return return_hash
  end

  def organisations
    ['department-for-transport', 'high-speed-two-limited']
  end

  def rummager_empty
    { "results" => [],
      "total" => 100,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [],
          "documents_with_no_value" => 80,
          "total_options" => 10,
          "missing_options" => 10,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => [] }
  end

  def rummager_totals
    { "results" => [],
      "total" => 100,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 20 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 80 }
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => [] }
  end

  def rummager_untagged
    { "results" => [],
      "total" => 50,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 5 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 45 }
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => [] }
  end

  def rummager_zeros
    { "results" => [],
      "total" => 50,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "department-for-transport" }, "documents" => 0 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 0 }
          ],
          "documents_with_no_value" => 0,
          "total_options" => 2,
          "missing_options" => 2,
          "scope" => "all_filters"
        }
      },
      "suggested_queries" => [] }
  end
end
