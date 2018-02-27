require 'rails_helper'
require 'gds_api/test_helpers/rummager'
include ::GdsApi::TestHelpers::Rummager

RSpec.describe Tagging::CommonAncestorFinder do
  context 'there is one taxon' do
    def has_paths(paths)
      publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', paths))
    end

    before :each do
      stub_any_rummager_search.to_return(body: { 'results' => [{ 'content_id' => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' }] }.to_json)
    end

    it 'returns nothing' do
      has_paths []
      result = Tagging::CommonAncestorFinder.new.find_all.force
      expect(result).to be_empty
    end
    it 'has one path and return nothing' do
      has_paths [[1, 2, 3, 4]]
      result = Tagging::CommonAncestorFinder.new.find_all.force
      expect(result).to be_empty
    end
    it 'has two paths, no common ancestor and returns nothing' do
      has_paths [[1, 2, 3, 4], [1, 2, 3, 5]]
      result = Tagging::CommonAncestorFinder.new.find_all.force
      expect(result).to be_empty
    end
    it 'has two paths, one common ancestor, returns the common ancestor' do
      has_paths [[1, 2, 3, 4], [1, 2, 3]]
      result = Tagging::CommonAncestorFinder.new.find_all
      expect(result.first[:common_ancestors]).to match_array([3])
    end
    it 'has three paths, one common ancestor, returns the common ancestor' do
      has_paths [[1, 2, 3, 4], [1, 2, 3], [1, 2, 5]]
      result = Tagging::CommonAncestorFinder.new.find_all
      expect(result.first[:common_ancestors]).to match_array([3])
    end
    it 'has five paths, two common ancestors, returns the common ancestors' do
      has_paths [[1, 2, 3, 4], [1, 2, 3], [1, 2, 5], [1, 2, 5, 9], [1, 2, 5, 11]]
      result = Tagging::CommonAncestorFinder.new.find_all
      expect(result.first[:common_ancestors]).to match_array([3, 5])
    end
    it 'has four paths, three common ancestors, returns all ancestors' do
      has_paths [[1], [1, 2, 3], [1, 2], [1, 2, 3, 4]]
      result = Tagging::CommonAncestorFinder.new.find_all
      expect(result.first[:common_ancestors]).to match_array([1, 2, 3])
    end
    it 'has separate branches, returns all ancestors' do
      has_paths [[1], [1, 2, 3], [5, 6], [5, 6, 7]]
      result = Tagging::CommonAncestorFinder.new.find_all
      expect(result.first[:common_ancestors]).to match_array([1, 6])
    end
  end

  it 'rejects empty content_ids' do
    stub_any_rummager_search.to_return(body: { 'results' => [{ 'content_id' => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' }, {}] }.to_json)
    publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', [[1], [1, 2]]))
    expect(Tagging::CommonAncestorFinder.new.find_all.force.length).to eq(1)
  end

  it 'includes title and content_id' do
    stub_any_rummager_search.to_return(body: { 'results' => [{ 'content_id' => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                                                               'title' => 'my title' }] }.to_json)
    publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', [[1], [1, 2]]))
    result_hash = Tagging::CommonAncestorFinder.new.find_all.force.first
    expect(result_hash[:title]).to eq('my title')
    expect(result_hash[:content_id]).to eq('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')
  end

  it 'rejects empty results' do
    stub_any_rummager_search.to_return(body: { 'results' => [{ 'content_id' => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' }] }.to_json)
    publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', [[]]))
    expect(Tagging::CommonAncestorFinder.new.find_all.force).to be_empty
  end
end
