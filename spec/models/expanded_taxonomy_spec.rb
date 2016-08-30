require "rails_helper"

RSpec.describe ExpandedTaxonomy do
  describe "#build" do
    def fake_taxon(title)
      { "title" => title, "content_id" => "#{title.parameterize}-id" }
    end

    let(:food)   { fake_taxon("Food") }
    let(:fruits) { fake_taxon("Fruits") }
    let(:apples) { fake_taxon("Apples") }
    let(:pears)  { fake_taxon("Pears") }

    before do
      publishing_api_has_item(food)

      publishing_api_has_expanded_links(
        content_id: food["content_id"],
        expanded_links: {
          child_taxons: [fruits]
        },
      )
      publishing_api_has_expanded_links(
        content_id: fruits["content_id"],
        expanded_links: {
          parent_taxons: [food],
          child_taxons: [apples, pears]
        },
      )
      publishing_api_has_expanded_links(
        content_id: pears["content_id"],
        expanded_links: {
          parent_taxons: [fruits],
        },
      )
      publishing_api_has_expanded_links(
        content_id: apples["content_id"],
        expanded_links: {
          parent_taxons: [fruits]
        },
      )
    end

    context "given a starting taxon" do
      let(:taxonomy) { ExpandedTaxonomy.new(food["content_id"]).build }

      it "returns a tree object representing the taxonomy from the starting taxon down" do
        expect(taxonomy.count).to eq 4
        expect(taxonomy.map(&:title)).to eq %w( Food Fruits Apples Pears)
        expect(taxonomy.map(&:node_depth)).to eq [0, 1, 2, 2]
      end
    end
  end
end
