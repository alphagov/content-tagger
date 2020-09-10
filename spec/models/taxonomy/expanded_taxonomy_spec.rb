require "rails_helper"

RSpec.describe Taxonomy::ExpandedTaxonomy do
  include ContentItemHelper

  home_page = FactoryBot.build(:taxon_hash, :home_page)

  # parent taxons
  let(:food) { FactoryBot.build(:taxon_hash, title: "Food") }
  let(:fruits) { FactoryBot.build(:taxon_hash, title: "Fruits", links: { parent_taxons: [food] }) }

  # our 'root' taxon
  let(:apples) { FactoryBot.build(:taxon_hash, title: "Apples") }

  # child taxons
  let(:bramley) { FactoryBot.build(:taxon_hash, title: "Bramley") }
  let(:cox) { FactoryBot.build(:taxon_hash, title: "Cox") }

  context "A child and parent taxon, not attached to the root taxon" do
    before :each do
      @rootless_parent = FactoryBot.build(:taxon_hash, title: "Rootless Parent")
      @rootless_child = FactoryBot.build(:taxon_hash, title: "Rootless Child")

      stub_publishing_api_has_item(@rootless_parent)
      stub_publishing_api_has_item(@rootless_child)

      stub_publishing_api_has_expanded_links({
        content_id: @rootless_parent["content_id"],
        expanded_links: {
          child_taxons: [@rootless_child],
        },
      })

      stub_publishing_api_has_expanded_links({
        content_id: @rootless_child["content_id"],
        expanded_links: {
          parent_taxons: [@rootless_parent],
        },
      })
    end

    describe "Rootless taxonomies" do
      describe 'Build a taxonomy where the selected ("root") taxon is the child' do
        it "Only contains the parent taxon" do
          taxonomy = Taxonomy::ExpandedTaxonomy.new(@rootless_child["content_id"]).build
          expect(taxonomy.parent_expansion.children.map(&:content_id)).to eq([@rootless_parent["content_id"]])
        end
      end
      describe 'Build a taxonomy where the selected ("root") taxon is the parent' do
        it "has no parents" do
          taxonomy = Taxonomy::ExpandedTaxonomy.new(@rootless_parent["content_id"]).build
          expect(taxonomy.parent_expansion.children).to be_empty
        end
      end
    end
  end

  before :each do
    stub_publishing_api_has_item(home_page)
    stub_publishing_api_has_item(food)

    stub_publishing_api_has_expanded_links({
      content_id: GovukTaxonomy::ROOT_CONTENT_ID,
      expanded_links: {
        level_one_taxons: [apples],
      },
    })

    stub_publishing_api_has_expanded_links({
      content_id: food["content_id"],
      expanded_links: {
        root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
      },
    })

    stub_publishing_api_has_item(apples)

    stub_publishing_api_has_expanded_links({
      content_id: apples["content_id"],
      expanded_links: {
        parent_taxons: [fruits],
        child_taxons: [bramley, cox],
      },
    })

    stub_publishing_api_has_expanded_links({
      content_id: bramley["content_id"],
      expanded_links: {
        parent_taxons: [apples],
      },
    })

    stub_publishing_api_has_expanded_links({
      content_id: cox["content_id"],
      expanded_links: {
        parent_taxons: [apples],
      },
    })
  end

  describe "Ask for the Homepage" do
    before :each do
      @taxonomy = Taxonomy::ExpandedTaxonomy.new(GovukTaxonomy::ROOT_CONTENT_ID).build
    end
    it "has no parent children" do
      expect(@taxonomy.parent_expansion.children).to be_empty
    end
    it "has apples as direct children" do
      expect(@taxonomy.child_expansion.children.count).to eq(1)
      expect(@taxonomy.child_expansion.children.first.internal_name).to eq("i-Apples")
    end
    it "has bramley and cox as grand children" do
      expect(@taxonomy.child_expansion.children.first.children.count).to eq(2)
      expect(@taxonomy.child_expansion.children.first.children.map(&:internal_name)).to match_array(%w[i-Bramley i-Cox])
    end
    it "has the correct name for the home page taxon" do
      expect(@taxonomy.root_node.internal_name).to eq("GOV.UK homepage")
    end
  end

  describe "#build" do
    it "returns a representation of the taxonomy, with both parent and child taxons expanded" do
      taxonomy = Taxonomy::ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.root_node.internal_name).to eq "i-Apples"
      expect(taxonomy.parent_expansion.map(&:internal_name)).to eq [
        "i-Apples",
        "i-Fruits",
        "i-Food",
        "GOV.UK homepage",
      ]
      expect(taxonomy.parent_expansion.map(&:depth)).to eq [0, 1, 2, 3]
      expect(taxonomy.child_expansion.map(&:internal_name)).to eq %w[
        i-Apples
        i-Bramley
        i-Cox
      ]
      expect(taxonomy.child_expansion.map(&:depth)).to eq [0, 1, 1]
    end
  end

  describe "#immediate_parents" do
    it "returns immediate parents of the root node" do
      taxonomy = Taxonomy::ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_parents.map(&:internal_name)).to eq %w[
        i-Fruits
      ]
    end
  end

  describe "#immediate_children" do
    it "returns immediate children of the root node" do
      taxonomy = Taxonomy::ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_children.map(&:internal_name)).to eq %w[
        i-Bramley
        i-Cox
      ]
    end
  end

  describe "#child_expansion" do
    let(:taxonomy) { Taxonomy::ExpandedTaxonomy.new(apples["content_id"]) }

    context "when the expansion hasn't been built yet" do
      it "raises an error" do
        expect { taxonomy.child_expansion }.to raise_error(
          Taxonomy::ExpandedTaxonomy::ExpansionNotBuiltError,
        )
      end
    end

    context "when the expansion has been built" do
      it "returns the expansion" do
        taxonomy.build

        expect(taxonomy.child_expansion.map(&:internal_name)).to eq %w[i-Apples i-Bramley i-Cox]
        expect(taxonomy.child_expansion.map(&:depth)).to eq [0, 1, 1]
      end
    end

    context "given a circular dependency between taxons" do
      let(:bramley) do
        FactoryBot.build(:taxon_hash, title: "Bramley", links: { parent_taxons: [apples], child_taxons: [apples] })
      end

      it "ensures the same traversal isn't rendered more than once" do
        taxonomy.build

        tree = taxonomy.child_expansion.map do |child_node|
          [child_node.depth, child_node.internal_name]
        end

        expect(tree).to eq(
          [[0, "i-Apples"], [1, "i-Bramley"], [2, "i-Apples"], [1, "i-Cox"]],
        )
      end
    end
  end

  describe "#parent_expansion" do
    let(:taxonomy) { Taxonomy::ExpandedTaxonomy.new(apples["content_id"]) }

    context "when the expansion hasn't been built yet" do
      it "raises an error" do
        expect { taxonomy.parent_expansion }.to raise_error(
          Taxonomy::ExpandedTaxonomy::ExpansionNotBuiltError,
        )
      end
    end

    context "when the expansion has been built" do
      it "returns the expansion" do
        taxonomy.build

        expect(taxonomy.parent_expansion.map(&:internal_name)).to eq ["i-Apples", "i-Fruits", "i-Food", "GOV.UK homepage"]
        expect(taxonomy.parent_expansion.map(&:depth)).to eq [0, 1, 2, 3]
      end
    end
  end
end
