require "gds_api/test_helpers/search"

RSpec.describe Tagging::CommonAncestorFinder do
  include ::GdsApi::TestHelpers::Search

  context "when there is one taxon" do
    def has_paths(paths)
      stub_publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", paths))
    end

    before do
      stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }] }.to_json)
    end

    it "returns nothing" do
      has_paths []
      result = described_class.new.find_all.force
      expect(result).to be_empty
    end

    it "has one path and return nothing" do
      has_paths [[1, 2, 3, 4]]
      result = described_class.new.find_all.force
      expect(result).to be_empty
    end

    it "has two paths, no common ancestor and returns nothing" do
      has_paths [[1, 2, 3, 4], [1, 2, 3, 5]]
      result = described_class.new.find_all.force
      expect(result).to be_empty
    end

    it "has two paths, one common ancestor, returns the common ancestor" do
      has_paths [[1, 2, 3, 4], [1, 2, 3]]
      result = described_class.new.find_all
      expect(result.first[:common_ancestors]).to contain_exactly(3)
    end

    it "has three paths, one common ancestor, returns the common ancestor" do
      has_paths [[1, 2, 3, 4], [1, 2, 3], [1, 2, 5]]
      result = described_class.new.find_all
      expect(result.first[:common_ancestors]).to contain_exactly(3)
    end

    it "has five paths, two common ancestors, returns the common ancestors" do
      has_paths [[1, 2, 3, 4], [1, 2, 3], [1, 2, 5], [1, 2, 5, 9], [1, 2, 5, 11]]
      result = described_class.new.find_all
      expect(result.first[:common_ancestors]).to contain_exactly(3, 5)
    end

    it "has four paths, three common ancestors, returns all ancestors" do
      has_paths [[1], [1, 2, 3], [1, 2], [1, 2, 3, 4]]
      result = described_class.new.find_all
      expect(result.first[:common_ancestors]).to contain_exactly(1, 2, 3)
    end

    it "has separate branches, returns all ancestors" do
      has_paths [[1], [1, 2, 3], [5, 6], [5, 6, 7]]
      result = described_class.new.find_all
      expect(result.first[:common_ancestors]).to contain_exactly(1, 6)
    end
  end

  it "rejects empty content_ids" do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }, {}] }.to_json)
    stub_publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", [[1], [1, 2]]))
    expect(described_class.new.find_all.force.length).to eq(1)
  end

  it "includes title and content_id" do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                                      "title" => "my title" }] }.to_json)
    stub_publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", [[1], [1, 2]]))
    result_hash = described_class.new.find_all.force.first
    expect(result_hash[:title]).to eq("my title")
    expect(result_hash[:content_id]).to eq("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
  end

  it "rejects empty results" do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }] }.to_json)
    stub_publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", [[]]))
    expect(described_class.new.find_all.force).to be_empty
  end

  it "tries again if timed out" do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }] }.to_json)
    stub_any_publishing_api_call.to_return(
      { status: 504 },
      { status: 504 },
      status: 200,
      body: Support::TaxonHelper.expanded_link_hash("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", [[1], [1, 2]]).to_json,
    )
    result_hash = described_class.new.find_all.force.first
    expect(result_hash[:content_id]).to eq("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
  end

  it "only tries 3 times" do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }] }.to_json)
    stub_any_publishing_api_call.to_return(
      { status: 504 },
      { status: 504 },
      status: 504,
    )
    expect { described_class.new.find_all.force.first }.to raise_error(GdsApi::HTTPGatewayTimeout)
  end
end
