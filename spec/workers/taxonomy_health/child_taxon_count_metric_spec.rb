RSpec.describe TaxonomyHealth::ChildTaxonCountMetric do
  let(:home_page) do
    FactoryBot.build(
      :taxon_hash,
      :home_page,
      expanded_links: { level_one_taxons: [food] },
    )
  end
  let(:food) do
    FactoryBot.build(
      :taxon_hash,
      title: "Food",
      expanded_links: {
        child_taxons: [fruits, vegetables, meats],
        root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
      },
    )
  end
  let(:fruits) { FactoryBot.build(:taxon_hash, title: "Fruits") }
  let(:vegetables) { FactoryBot.build(:taxon_hash, title: "Vegetables") }
  let(:meats) { FactoryBot.build(:taxon_hash, title: "Meats") }

  before do
    stub_publishing_api_has_item(home_page)
    stub_publishing_api_has_item(food)
    stub_publishing_api_has_item(fruits)
    stub_publishing_api_has_item(vegetables)
    stub_publishing_api_has_item(meats)

    stub_publishing_api_has_expanded_links(home_page)
    stub_publishing_api_has_expanded_links(food)
  end

  it "records no failing taxons" do
    expect { described_class.new.perform(maximum: 3, minimum: 1) }
      .not_to(change(Taxonomy::HealthWarning, :count))
  end

  it "records a failing taxon with too many children" do
    expect { described_class.new.perform(maximum: 2) }
      .to(change(Taxonomy::HealthWarning, :count).by(1))

    expect(Taxonomy::HealthWarning.last.content_id).to eq(food["content_id"])
  end

  it "records a failing taxon with too few children - excluding leaf nodes" do
    expect { described_class.new.perform(maximum: 3, minimum: 2) }
      .to(change(Taxonomy::HealthWarning, :count).by(1))

    expect(Taxonomy::HealthWarning.last.content_id).to eq(home_page["content_id"])
  end
end
