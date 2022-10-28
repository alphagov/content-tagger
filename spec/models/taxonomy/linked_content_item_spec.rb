RSpec.describe Taxonomy::LinkedContentItem do
  let(:root_node) { described_class.new(title: "root-id", content_id: "abc", base_path: "/root-id") }
  let(:child_node_1) { described_class.new(title: "child-1-id", content_id: "abc", base_path: "/child-1-id") }

  describe "#<<(child_node)" do
    it "makes one node the child of another node" do
      root_node << child_node_1

      expect(root_node.tree).to include child_node_1
      expect(child_node_1.parent).to eq root_node
    end
  end

  describe "#tree" do
    context "when given a node with a tree of successors" do
      it "returns an array representing a pre-order traversal of the tree" do
        child_node_2 = described_class.new(title: "child-2-id", content_id: "abc", base_path: "/child-2-id")
        child_node_3 = described_class.new(title: "child-3-id", content_id: "abc", base_path: "/child-3-id")

        root_node << child_node_1
        child_node_1 << child_node_3
        child_node_1 << child_node_2

        expect(root_node.tree.count).to eq 4
        expect(root_node.tree.first).to eq root_node
        expect(root_node.tree.map(&:title)).to eq %w[root-id child-1-id child-3-id child-2-id]
        expect(child_node_1.tree.map(&:title)).to eq %w[child-1-id child-3-id child-2-id]
      end
    end

    context "when given a single node" do
      it "returns an array containing only that node" do
        expect(root_node.tree.map(&:title)).to eq %w[root-id]
      end
    end
  end

  describe "#root?" do
    before do
      root_node << child_node_1
    end

    it "returns true when a node is the root" do
      expect(root_node.root?).to be(true)
    end

    it "returns false when a node is not the root" do
      expect(child_node_1.root?).to be(false)
    end
  end

  describe "#depth" do
    it "returns the depth of the node in its tree" do
      child_node_2 = described_class.new(title: "child-2-id", content_id: "abc", base_path: "/child-2-id")
      root_node << child_node_1
      child_node_1 << child_node_2

      expect(root_node.depth).to eq 0
      expect(child_node_1.depth).to eq 1
      expect(child_node_2.depth).to eq 2
    end
  end

  context "when there is a taxon with ancestors" do
    let(:child_node_2) do
      described_class.new(
        title: "child-2-id",
        content_id: "abc",
        base_path: "/child-2-id",
      )
    end

    before do
      root_node << child_node_1
      child_node_1 << child_node_2
    end

    describe "#breadcrumb_trail" do
      it "includes the ancestors plus the content item itself" do
        expect(child_node_2.breadcrumb_trail.map(&:title)).to eq %w[root-id child-1-id child-2-id]
      end

      it "is just contains itself for the root node" do
        expect(root_node.breadcrumb_trail.map(&:title)).to eq %w[root-id]
      end
    end

    describe "#ancestors" do
      it "includes the ancestors but not the content item itself" do
        expect(child_node_2.ancestors.map(&:title)).to eq %w[root-id child-1-id]
      end

      it "is the reverse of #descendants" do
        have_descendant_node = lambda do |ancestor|
          ancestor.descendants.include?(child_node_2)
        end

        expect(child_node_2.ancestors).to all(satisfy(&have_descendant_node))
      end

      it "is an empty array for the root node" do
        expect(root_node.ancestors).to be_empty
      end
    end

    describe "#taxons" do
      let(:content_item) do
        described_class.new(
          title: "content",
          content_id: "abc",
          base_path: "/content",
        )
      end

      it "includes only the directly linked taxons" do
        content_item.add_taxon(child_node_2)

        expect(content_item.taxons.map(&:title)).to eq ["child-2-id"]
      end
    end

    describe "#taxons_with_ancestors" do
      let(:another_taxon) do
        described_class.new(
          title: "another-taxon",
          content_id: "abc",
          base_path: "/another-taxon",
        )
      end

      let(:content_item) do
        described_class.new(
          title: "content",
          content_id: "abc",
          base_path: "/content",
        )
      end

      it "includes all of the taxons and all of their anscestors" do
        content_item.add_taxon(child_node_2)
        content_item.add_taxon(another_taxon)

        expect(content_item.taxons_with_ancestors.map(&:title).sort).to eq %w[another-taxon child-1-id child-2-id root-id]
      end
    end
  end
end
