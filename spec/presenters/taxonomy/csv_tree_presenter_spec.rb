require "rails_helper"

module Taxonomy
  RSpec.describe CsvTreePresenter do
    include ContentItemHelper

    describe "#present" do
      let(:root_node) do
        GovukTaxonomyHelpers::LinkedContentItem.new(internal_name: "root", base_path: "/root", content_id: "Root", title: "Root")
      end

      let(:child_node_1) do
        GovukTaxonomyHelpers::LinkedContentItem.new(internal_name: "child-1", base_path: "/Child-1", content_id: "Child-1", title: "Child-1")
      end

      let(:child_node_2) do
        GovukTaxonomyHelpers::LinkedContentItem.new(internal_name: "child-2", base_path: "/Child-2", content_id: "Child-2", title: "Child-2")
      end

      let(:child_node_3) do
        GovukTaxonomyHelpers::LinkedContentItem.new(internal_name: "child-3", base_path: "/Child-3", content_id: "Child-3", title: "Child-3")
      end

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
