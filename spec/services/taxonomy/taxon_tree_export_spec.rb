require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe Taxonomy::TaxonTreeExport do
  include PublishingApiHelper
  include ContentItemHelper

  let(:taxon_id) { "123456" }

  describe "#initialize" do
    subject { described_class.new(taxon_id) }

    it "class should instantiate with 1 argument" do
      expect(subject).to be_an_instance_of(TaxonTreeExport)
      expect(subject.taxon_content_id).to eq(taxon_id)
    end
  end

  describe "#expanded_taxon" do
    subject { described_class.new(taxon_id) }

    it "should return a ExpandedTaxonomy instance" do
      publishing_api_has_item(content_id: taxon_id, title: 'content')
      expect(subject.expanded_taxon).to be_an_instance_of(ExpandedTaxonomy)
    end
  end

  describe "#flattern_taxonomy" do
    # level 1 taxon
    let(:transport) { fake_taxon("Transport") }

    # level 2 taxon
    let(:vehicles) do
      fake_taxon("Vehicles").merge(
        "links" => {
          "parent_taxons" => [transport],
          "child_taxons" => [car]
        }
      )
    end

    # level 3 taxon
    let(:car) { fake_taxon("Car") }

    let(:subject) { described_class.new(transport['content_id']) }

    before do
      publishing_api_has_item(transport)
      publishing_api_has_item(vehicles)
      publishing_api_has_item(car)

      publishing_api_has_expanded_links(
        content_id: transport['content_id'],
        expanded_links: {
          root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
          child_taxons: [vehicles]
        }
      )

      publishing_api_has_expanded_links(
        content_id: vehicles["content_id"],
        expanded_links: {
          parent_taxons: [transport],
          child_taxons: [car],
        }
      )

      publishing_api_has_expanded_links(
        content_id: car["content_id"],
        expanded_links: {
          parent_taxons: [vehicles]
        }
      )

      expanded_taxon_tree = subject.expanded_taxon.build
      @flattened_tree = subject.flatten_taxonomy(expanded_taxon_tree.child_expansion)
    end

    it "should flatten the taxon tree" do
      expect(@flattened_tree.length).to be(3)
    end

    it "returned flattened tree should include the children and grand-children of a taxon item" do
      expect(@flattened_tree).to include(
        a_hash_including(
          base_path: "/path/transport",
          title: "Transport",
          links: a_hash_including(
            child_taxons: [a_hash_including(
              base_path: "/path/vehicles",
              title: "Vehicles",
              links: a_hash_including(
                child_taxons: [a_hash_including(
                  base_path: "/path/car",
                  title: "Car"
                )]
              )
            )]
          )
        )
      )
    end

    it "returned flattened tree should include the parent of a taxon item" do
      expect(@flattened_tree).to include(
        a_hash_including(
          base_path: "/path/vehicles",
          title: "Vehicles",
          links: a_hash_including(
            parent_taxons: [a_hash_including(
              base_path: "/path/transport",
              title: "Transport"
            )]
          )
        )
      )
    end
  end

  def fake_taxon(title)
    content_item_with_details(title)
  end
end
