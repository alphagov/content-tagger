require 'rails_helper'

RSpec.describe TaxonSearchResults do
  let(:search_response) do
    {
      'current_page' => 1,
      'pages' => 2,
      'results' => [{ 'content_id' => 'id-1' }, { 'content_id' => 'id-2' }]
    }
  end
  let(:search_results) { described_class.new(search_response) }

  it 'has access to taxons' do
    expect(search_results.taxons.length).to eq(2)
  end

  it 'returns instances of Taxons' do
    search_results.taxons.each do |taxon|
      expect(taxon).to be_a(Taxon)
    end
  end

  it 'knows about the current page' do
    expect(search_results.current_page).to eq(1)
  end

  it 'knows about the total number of pages' do
    expect(search_results.total_pages).to eq(2)
  end

  it 'knows about the limit value so it works with kaminari' do
    expect(search_results.limit_value).to eq(5)
  end

  context 'when unpublished items are in the results' do
    let(:search_response) do
      {
        'results' => [
          { 'content_id' => 'id-1', 'publication_state' => 'published' },
          { 'content_id' => 'id-2', 'publication_state' => 'unpublished' },
        ]
      }
    end

    it 'filters them out' do
      expect(search_results.taxons.count).to eq 1
    end
  end
end
