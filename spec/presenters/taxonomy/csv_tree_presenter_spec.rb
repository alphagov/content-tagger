require "rails_helper"

module Taxonomy
  RSpec.describe CsvTreePresenter do
    include ContentItemHelper

    describe "#present" do
      let(:root_node) { TreeNode.new(name: "root", content_item: ContentItem.new(basic_content_item("Root"))) }
      let(:child_node_1) { TreeNode.new(name: "child-1", content_item: ContentItem.new(basic_content_item("Child-1"))) }
      let(:child_node_2) { TreeNode.new(name: "child-2", content_item: ContentItem.new(basic_content_item("Child-2"))) }
      let(:child_node_3) { TreeNode.new(name: "child-3", content_item: ContentItem.new(basic_content_item("Child-3"))) }

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
end
