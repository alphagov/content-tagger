require 'rails_helper'

RSpec.describe LegacyTaxonomy::Client::SearchApi do
  subject { described_class }

  describe ".content_from_rummager" do
    before do
      mock_client = instance_double(GdsApi::Rummager)
      allow(subject).to receive(:client).and_return(mock_client)
      allow(mock_client).to receive(:search).and_return(search_data)
    end

    let(:search_data) do
      {
        'results' => [
          {
            'content_id' => 'foo',
            'link' => 'bar',
            'other data' => 'baz'
          },
          {
            'link' => 'this one has a blank content_id',
            'content_id' => ''
          },
          {
            'content_id' => 'no link for this one'
          }
        ]
      }
    end

    let(:result) { subject.content_from_rummager }

    it "returns an array" do
      expect(result).to be_an Array
    end

    it "each result is a hash of content_id and link" do
      result.each do |res|
        expect(res.keys).to eq %w[content_id link]
      end
    end

    it "doesn't return results with incomplete data" do
      expect(result.size).to eq 1
    end
  end
end
