RSpec.describe Taxonomy::LevelOneTaxonsRetrieval do
  let(:child_contents) { Array.new(2) { { "content_id" => SecureRandom.uuid } } }

  before do
    stub_publishing_api_has_expanded_links({
      "content_id" => GovukTaxonomy::ROOT_CONTENT_ID,
      "expanded_links" => {
        "level_one_taxons" => child_contents,
      },
    })
  end

  it "gets the taxonomy roots" do
    expect(described_class.new.get).to match_array(child_contents)
  end
end
