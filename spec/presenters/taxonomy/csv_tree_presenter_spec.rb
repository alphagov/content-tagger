module Taxonomy
  RSpec.describe CsvTreePresenter do
    include ContentItemHelper

    describe "#present" do
      let(:root_node) do
        LinkedContentItem.new(internal_name: "root", base_path: "/root", content_id: "Root", title: "Root")
      end

      let(:child_node_one) do
        LinkedContentItem.new(internal_name: "child-1", base_path: "/Child-1", content_id: "Child-1", title: "Child-1")
      end

      let(:child_node_two) do
        LinkedContentItem.new(internal_name: "child-2", base_path: "/Child-2", content_id: "Child-2", title: "Child-2")
      end

      let(:child_node_three) do
        LinkedContentItem.new(internal_name: "child-3", base_path: "/Child-3", content_id: "Child-3", title: "Child-3")
      end

      before do
        root_node << child_node_one
        child_node_one << child_node_two
        child_node_one << child_node_three
      end

      it "presents the tree in CSV form" do
        document_counts = {
          "facets" => {
            "taxons" => {
              "options" => [
                { "value" => { "slug" => "Root" }, "documents" => 1 },
                { "value" => { "slug" => "Child-1" }, "documents" => 2 },
                { "value" => { "slug" => "Child-2" }, "documents" => 3 },
                { "value" => { "slug" => "Child-3" }, "documents" => 4 },
              ],
            },
          },
        }

        stub_request(:get, "https://search-api.test.gov.uk/search.json?count=0&facet_taxons=4000")
            .to_return(body: document_counts.to_json)

        presented = described_class.new(root_node).present

        expect(presented.split("\n")).to eq %w[Root,1 ,Child-1,2 ,,Child-2,3 ,,Child-3,4]
      end
    end
  end
end
