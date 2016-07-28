require 'rails_helper'

RSpec.describe BulkTagging::FetchRemoteData do
  include GoogleSheetHelper

  describe "#run" do
    let(:url) { URI "https://remote-data/path" }
    let(:tagging_spreadsheet) { TaggingSpreadsheet.new(url: url) }

    before do
      allow(Net::HTTP).to receive(:get).with(url).and_return(google_sheet_fixture)
    end

    it "retrieves data from the tagging spreadsheet URL" do
      expect(Net::HTTP).to receive(:get).with(url)

      BulkTagging::FetchRemoteData.new(tagging_spreadsheet).run
    end

    it "creates tag mappings based on the retrieved data" do
      BulkTagging::FetchRemoteData.new(tagging_spreadsheet).run

      expect(TagMapping.all.map(&:content_base_path)).to eq(%w(/content-1/ /content-1/ /content-1/ /content-2/))
      expect(TagMapping.all.map(&:link_type)).to eq(%w(taxons taxons organisations taxons))
    end
  end
end
