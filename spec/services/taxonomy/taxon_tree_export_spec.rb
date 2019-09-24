require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe Taxonomy::TaxonTreeExport do
  include PublishingApiHelper
  include ContentItemHelper

  # level 1 taxon
  let(:transport) { fake_taxon("Transport") }

  # level 2 taxon
  let(:vehicles) do
    fake_taxon("Vehicles").merge(
      "links" => {
        "parent_taxons" => [transport],
        "child_taxons" => [car],
      },
    )
  end

  # level 3 taxon
  let(:car) { fake_taxon("Car") }

  let(:subject) { described_class.new(transport["content_id"]) }
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
      publishing_api_has_item(content_id: taxon_id, title: "content")
      expect(subject.expanded_taxon).to be_an_instance_of(ExpandedTaxonomy)
    end
  end

  describe "#flattern_taxonomy" do
    before do
      fake_taxonomy_tree(transport, vehicles, car)
      expanded_taxon_tree = subject.expanded_taxon.build
      @flattened_tree = subject.flatten_taxonomy(expanded_taxon_tree.child_expansion)
    end

    it "should flatten the taxon tree" do
      expect(@flattened_tree.length).to be(3)
    end

    it "returned flattened tree should include the children and grand-children of a taxon item" do
      expect(@flattened_tree).to include(
        a_hash_including(
          base_path: "/level-one/transport",
          title: "Transport",
          links: a_hash_including(
            child_taxons: [a_hash_including(
              base_path: "/level-one/vehicles",
              title: "Vehicles",
              links: a_hash_including(
                child_taxons: [a_hash_including(
                  base_path: "/level-one/car",
                  title: "Car",
                )],
              ),
            )],
          ),
        ),
      )
    end

    it "returned flattened tree should include the parent of a taxon item" do
      expect(@flattened_tree).to include(
        a_hash_including(
          base_path: "/level-one/vehicles",
          title: "Vehicles",
          links: a_hash_including(
            parent_taxons: [a_hash_including(
              base_path: "/level-one/transport",
              title: "Transport",
            )],
          ),
        ),
      )
    end
  end

  describe "#build" do
    before do
      fake_taxonomy_tree(transport, vehicles, car)
    end

    it "should return taxonomy tree as a JSON object" do
      taxon_tree = subject.build
      expect(valid_json?(taxon_tree)).to be_truthy
    end
  end

  def fake_taxon(title)
    content_item_with_details(title)
  end

  def fake_taxonomy_tree(level_1_taxon, level_2_taxon, level_3_taxon)
    publishing_api_has_item(level_1_taxon)
    publishing_api_has_item(level_2_taxon)
    publishing_api_has_item(level_3_taxon)

    publishing_api_has_expanded_links(
      content_id: level_1_taxon["content_id"],
      expanded_links: {
        root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
        child_taxons: [level_2_taxon],
      },
    )

    publishing_api_has_expanded_links(
      content_id: level_2_taxon["content_id"],
      expanded_links: {
        parent_taxons: [level_1_taxon],
        child_taxons: [level_3_taxon],
      },
    )

    publishing_api_has_expanded_links(
      content_id: level_3_taxon["content_id"],
      expanded_links: {
        parent_taxons: [level_2_taxon],
      },
    )
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end
end
