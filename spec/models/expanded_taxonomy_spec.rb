require "rails_helper"

RSpec.describe ExpandedTaxonomy do
  def fake_taxon(title)
    { "title" => title, "content_id" => "#{title.parameterize}-id" }
  end

  # parent taxons
  let(:red_things) { fake_taxon("Red-Things") }
  let(:food) { fake_taxon("Food") }
  let(:fruits) do
    fake_taxon("Fruits").merge(
      "links" => {
        "parent_taxons" => [food]
      }
    )
  end

  # our 'root' taxon
  let(:apples) { fake_taxon("Apples") }

  # child taxons
  let(:bramley) { fake_taxon("Bramley") }
  let(:cox) { fake_taxon("Cox") }

  before do
    publishing_api_has_item(apples)

    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: {
        parent_taxons: [fruits, red_things],
        child_taxons: [bramley, cox],
      },
    )

    publishing_api_has_expanded_links(
      content_id: bramley["content_id"],
      expanded_links: {
        parent_taxons: [apples]
      }
    )

    publishing_api_has_expanded_links(
      content_id: cox["content_id"],
      expanded_links: {
        parent_taxons: [apples]
      }
    )
  end

  describe "#build" do
    it "returns a representation of the taxonomy, with both parent and child taxons expanded" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.root_node.title).to eq apples["title"]
      expect(taxonomy.parent_expansion.map(&:title)).to eq %w(Apples Fruits Food Red-Things)
      expect(taxonomy.parent_expansion.map(&:node_depth)).to eq [0, 1, 2, 1]
      expect(taxonomy.child_expansion.map(&:title)).to eq %w(Apples Bramley Cox)
      expect(taxonomy.child_expansion.map(&:node_depth)).to eq [0, 1, 1]
    end
  end

  describe "#immediate_parents" do
    it "returns immediate parents of the root node" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_parents.map(&:title)).to eq %w(Fruits Red-Things)
    end
  end

  describe "#immediate_children" do
    it "returns immediate children of the root node" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_children.map(&:title)).to eq %w(Bramley Cox)
    end
  end

  describe "#child_expansion" do
    let(:taxonomy) { ExpandedTaxonomy.new(apples["content_id"]) }

    context "when the expansion hasn't been built yet" do
      it "raises an error" do
        expect { taxonomy.child_expansion }.to raise_error(
          ExpandedTaxonomy::ExpansionNotBuiltError
        )
      end
    end

    context "when the expansion has been built" do
      it "returns the expansion" do
        taxonomy.build_child_expansion

        expect(taxonomy.child_expansion.map(&:title)).to eq %w(Apples Bramley Cox)
        expect(taxonomy.child_expansion.map(&:node_depth)).to eq [0, 1, 1]
      end
    end

    context "given a circular dependency between taxons" do
      before do
        publishing_api_has_expanded_links(
          content_id: bramley["content_id"],
          expanded_links: {
            parent_taxons: [apples],
            child_taxons: [apples],
          }
        )
      end

      it "ensures the same traversal isn't rendered more than once" do
        taxonomy.build_child_expansion

        tree = taxonomy.child_expansion.map do |child_node|
          [child_node.node_depth, child_node.title]
        end

        expect(tree).to eq(
          [[0, "Apples"], [1, "Bramley"], [2, "Apples"], [1, "Cox"]]
        )
      end
    end
  end

  describe "#parent_expansion" do
    let(:taxonomy) { ExpandedTaxonomy.new(apples["content_id"]) }

    context "when the expansion hasn't been built yet" do
      it "raises an error" do
        expect { taxonomy.parent_expansion }.to raise_error(
          ExpandedTaxonomy::ExpansionNotBuiltError
        )
      end
    end

    context "when the expansion has been built" do
      it "returns the expansion" do
        taxonomy.build_parent_expansion

        expect(taxonomy.parent_expansion.map(&:title)).to eq %w(Apples Fruits Food Red-Things)
        expect(taxonomy.parent_expansion.map(&:node_depth)).to eq [0, 1, 2, 1]
      end
    end
  end
end
