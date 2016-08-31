require "rails_helper"

RSpec.describe CsvTreePresenter do
  describe "#present" do
    let(:root_node) { TreeNode.new(title: "Root", content_id: "root-id") }
    let(:child_node_1) { TreeNode.new(title: "Child-1", content_id: "child-1-id") }
    let(:child_node_2) { TreeNode.new(title: "Child-2", content_id: "child-2-id") }
    let(:child_node_3) { TreeNode.new(title: "Child-3", content_id: "child-3-id") }

    before do
      root_node << child_node_1
      child_node_1 << child_node_2
      child_node_1 << child_node_3
    end

    it "presents the tree in CSV form" do
      presented = CsvTreePresenter.new(root_node).present

      expect(presented.split("\n")).to eq %w(Root ,Child-1 ,,Child-2 ,,Child-3)
    end
  end
end
