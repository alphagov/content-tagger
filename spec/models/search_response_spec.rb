require 'rails_helper'

RSpec.describe SearchResponse do
  include ContentItemHelper

  context 'with a successful response' do
    let(:gds_api_response) do
      double(
        GdsApi::Response,
        code: 200,
        to_hash: {
          'results' => [
            basic_content_item('Content item 1'),
            basic_content_item('Content item 2'),
          ],
          'pages' => 1
        }
      )
    end

    it 'includes content item search results' do
      search_response =
        described_class.new(gds_api_response, 'document_collection')

      expect(search_response.results.length).to eq(2)
      search_response.results.each do |result|
        expect(result).to be_a(ContentItem)
      end
    end

    it 'does not have multiple pages when pages are 1' do
      expect(
        described_class.new(gds_api_response, 'document_collection').multiple_pages?
      ).to be_falsy
    end
  end
end
