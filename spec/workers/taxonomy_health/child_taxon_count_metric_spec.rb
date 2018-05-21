require "rails_helper"

RSpec.describe TaxonomyHealth::ChildTaxonCountMetric do
  let(:home_page) { FactoryBot.build(:taxon_hash, :home_page, expanded_links: { level_one_taxons: [food] }) }
  let(:food) do
    FactoryBot.build(:taxon_hash,
                     title: 'Food',
                     expanded_links: {
                       child_taxons: [fruits, vegetables, meats],
                       root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID]
                     })
  end
  let(:fruits) { FactoryBot.build(:taxon_hash, title: 'Fruits') }
  let(:vegetables) { FactoryBot.build(:taxon_hash, title: 'Vegetables') }
  let(:meats) { FactoryBot.build(:taxon_hash, title: 'Meats') }

  before :each do
    publishing_api_has_item(home_page)
    publishing_api_has_item(food)
    publishing_api_has_item(fruits)
    publishing_api_has_item(vegetables)
    publishing_api_has_item(meats)

    publishing_api_has_expanded_links(home_page)
    publishing_api_has_expanded_links(food)
  end

  it 'records no failing taxons' do
    expect { TaxonomyHealth::ChildTaxonCountMetric.new.perform(maximum: 3, minimum: 1) }.to_not(change { Taxonomy::HealthWarning.count })
  end

  it 'records a failing taxon with too many children' do
    expect { TaxonomyHealth::ChildTaxonCountMetric.new.perform(maximum: 2) }.to(change { Taxonomy::HealthWarning.count }.by(1))
    expect(Taxonomy::HealthWarning.last.content_id).to eq(food['content_id'])
  end

  it 'records a failing taxon with too few children - excluding leaf nodes' do
    expect { TaxonomyHealth::ChildTaxonCountMetric.new.perform(maximum: 3, minimum: 2) }.to(change { Taxonomy::HealthWarning.count }.by(1))
    expect(Taxonomy::HealthWarning.last.content_id).to eq(home_page['content_id'])
  end
end
