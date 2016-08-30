require "rails_helper"

RSpec.describe TreeNode do
  let(:root_node) { TreeNode.new(title: "Root", content_id: "root-id") }
  let(:child_node_1) { TreeNode.new(title: "Child-1", content_id: "child-1-id") }

  describe "#<<(child_node)" do
    it "makes one node the child of another node" do
      root_node << child_node_1

      expect(root_node.tree).to include child_node_1
      expect(child_node_1.parent).to eq root_node
    end
  end

  describe "#tree" do
    context "given a node with a tree of successors" do
      it "returns an array representing a pre-order traversal of the tree" do
        child_node_2 = TreeNode.new(title: "Child-2", content_id: "child-2-id")
        child_node_3 = TreeNode.new(title: "Child-3", content_id: "child-3-id")

        root_node << child_node_1
        child_node_1 << child_node_3
        child_node_1 << child_node_2

        expect(root_node.tree.count).to eq 4
        expect(root_node.tree.first).to eq root_node
        expect(root_node.tree.map(&:title)).to eq %w(Root Child-1 Child-3 Child-2)
        expect(child_node_1.tree.map(&:title)).to eq %w(Child-1 Child-3 Child-2)
      end
    end

    context "given a single node" do
      it "returns an array containing only that node" do
        expect(root_node.tree.map(&:title)).to eq %w(Root)
      end
    end
  end

  describe "#root?" do
    before do
      root_node << child_node_1
    end

    it "returns true when a node is the root" do
      expect(root_node.root?).to be
    end

    it "returns false when a node is not the root" do
      expect(child_node_1.root?).to_not be
    end
  end

  describe "#node_depth" do
    it "returns the depth of the node in its tree" do
      child_node_2 = TreeNode.new(title: "Child-2", content_id: "child-2-id")
      root_node << child_node_1
      child_node_1 << child_node_2

      expect(root_node.node_depth).to eq 0
      expect(child_node_1.node_depth).to eq 1
      expect(child_node_2.node_depth).to eq 2
    end
  end

  describe "#count" do
    it "returns the total number of nodes in the tree" do
      root_node << child_node_1

      expect(root_node.count).to eq 2
    end
  end
end
