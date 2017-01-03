require 'rails_helper'

module BulkTagging
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
            'pages' => 2,
            'current_page' => 1
          }
        )
      end

      let(:search_response) do
        described_class.new(gds_api_response, 'document_collection')
      end

      it 'includes content item search results' do
        expect(search_response.results.length).to eq(2)
        search_response.results.each do |result|
          expect(result).to be_a(ContentItem)
        end
      end

      it 'knows the total number of pages' do
        expect(search_response.total_pages).to eq(2)
      end

      it 'knows in which page the results are on' do
        expect(search_response.current_page).to eq(1)
      end

      it 'sets a limit number of pagination links to display' do
        expect(search_response.limit_value).to eq(5)
      end
    end
  end
end
