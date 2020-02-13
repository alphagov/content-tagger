require "rails_helper"

RSpec.describe TaxonomyHealth::MaximumDepthMetric do
  let(:home_page) { FactoryBot.build(:taxon_hash, :home_page, expanded_links: { level_one_taxons: [food] }) }
  let(:food) do
    FactoryBot.build(:taxon_hash,
                     title: "Food",
                     expanded_links: {
                       child_taxons: [fruits],
                       root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
                     })
  end
  let(:fruits) { FactoryBot.build(:taxon_hash, title: "Fruits", links: { child_taxons: [apples, pears] }) }
  let(:apples) { FactoryBot.build(:taxon_hash, title: "Apples") }
  let(:pears) { FactoryBot.build(:taxon_hash, title: "Pears") }

  before :each do
    stub_publishing_api_has_item(home_page)
    stub_publishing_api_has_item(food)
    stub_publishing_api_has_item(fruits)
    stub_publishing_api_has_item(apples)
    stub_publishing_api_has_item(pears)
    publishing_api_has_expanded_links(home_page)
    publishing_api_has_expanded_links(food)
  end

  it "records no failing taxons" do
    expect { TaxonomyHealth::MaximumDepthMetric.new.perform(maximum_depth: 5) }.to_not(change { Taxonomy::HealthWarning.count })
  end

  it "records level 3 taxons" do
    TaxonomyHealth::MaximumDepthMetric.new.perform(maximum_depth: 2)
    expect(Taxonomy::HealthWarning.pluck(:content_id)).to match_array([apples, pears].map { |taxon| taxon["content_id"] })
  end

  it "records level 2 and 3 taxons" do
    TaxonomyHealth::MaximumDepthMetric.new.perform(maximum_depth: 1)
    expect(Taxonomy::HealthWarning.pluck(:content_id)).to match_array([apples, pears, fruits].map { |taxon| taxon["content_id"] })
  end
end
