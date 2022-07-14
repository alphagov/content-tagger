require "rails_helper"
require "gds_api/test_helpers/search"

RSpec.describe "content:tagged_to_ancestor", type: :task do
  include RakeTaskHelper
  include ::GdsApi::TestHelpers::Search

  def has_paths(paths)
    stub_publishing_api_has_expanded_links(Support::TaxonHelper.expanded_link_hash(
                                             "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", paths
                                           ))
  end

  before :each do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }] }.to_json)
  end

  it "does nothing if there's nothing to do" do
    has_paths []
    expect { rake("content:tagged_to_ancestor") }.not_to raise_error
  end

  it "produces output if there's a common ancestor" do
    has_paths [[1, 2, 3, 4], [1, 2, 3]]
    expect {
      rake("content:tagged_to_ancestor")
    }.to output(/^Document .* content_id: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa has common ancestors tagged to: $/).to_stdout
  end

  it "optionally invokes untagger" do
    has_paths [[1, 2, 3, 4], [1, 2, 3]]

    untagger = double(Tagging::Untagger)
    expect(untagger).to receive(:call)
    stub_const("Tagging::Untagger", untagger)

    rake("content:tagged_to_ancestor", "untag")
  end
end
