require "gds_api/test_helpers/search"

RSpec.describe TaxonomyHealth::ContentCountMetric do
  include GdsApi::TestHelpers::Search
  let(:home_page) { FactoryBot.build(:taxon_hash, :home_page, expanded_links: { level_one_taxons: [food] }) }
  let(:food) do
    FactoryBot.build(
      :taxon_hash,
      title: "Food",
      expanded_links: {
        root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
      },
    )
  end
  let(:fruits) { FactoryBot.build(:taxon_hash, title: "Fruits") }

  before :each do
    stub_publishing_api_has_item(home_page)
    stub_publishing_api_has_item(food)
    stub_publishing_api_has_expanded_links(home_page)
    stub_publishing_api_has_expanded_links(food)
  end

  it "records no failing taxons" do
    allow(Taxonomy::ContentCounter).to receive(:count).with(home_page["content_id"]).and_return(0)
    allow(Taxonomy::ContentCounter).to receive(:count).with(food["content_id"]).and_return(1)
    expect { TaxonomyHealth::ContentCountMetric.new.perform(maximum: 5) }.to_not(change { Taxonomy::HealthWarning.count })
  end

  it "records a failing taxon" do
    allow(Taxonomy::ContentCounter).to receive(:count).with(home_page["content_id"]).and_return(0)
    allow(Taxonomy::ContentCounter).to receive(:count).with(food["content_id"]).and_return(10)
    expect { TaxonomyHealth::ContentCountMetric.new.perform(maximum: 5) }.to(change { Taxonomy::HealthWarning.count }.by(1))
    expect(Taxonomy::HealthWarning.last.content_id).to eq(food["content_id"])
  end
end
