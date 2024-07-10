module Taxonomy
  RSpec.describe LinkedContentItem::PublishingApiResponse do
    let(:content_item) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/taxon",
        "title" => "Taxon",
        "details" => {
          "internal_name" => "My lovely taxon",
        },
      }
    end
    let(:linked_content_item) do
      LinkedContentItem.from_content_id(
        content_id: content_item["content_id"],
        publishing_api:,
      )
    end

    let(:expanded_links) do
      child = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child",
        "title" => "Child",
        "details" => {
          "internal_name" => "C",
        },
        "links" => {},
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child],
        },
      }
    end

    let(:publishing_api) { instance_double(GdsApi::PublishingApi) }

    before do
      allow(publishing_api).to receive(:get_content).with("64aadc14-9bca-40d9-abb4-4f21f9792a05").and_return(content_item)
      allow(publishing_api).to receive(:get_expanded_links).with("64aadc14-9bca-40d9-abb4-4f21f9792a05").and_return(expanded_links)
    end

    describe "#from_content_id - simple one child case" do
      it "loads the taxon" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.children.map(&:title)).to eq(%w[Child])
        expect(linked_content_item.children.map(&:children)).to all(be_empty)
      end
    end

    context "when content item contain multiple levels of descendants" do
      let(:expanded_links) do
        grandchild1 = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandchild-1",
          "title" => "Grandchild 1",
          "details" => {
            "internal_name" => "GC 1",
          },
          "links" => {},
        }

        grandchild2 = {
          "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandchild-2",
          "title" => "Grandchild 2",
          "details" => {
            "internal_name" => "GC 2",
          },
          "links" => {},
        }

        child1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/child-1",
          "title" => "Child 1",
          "details" => {
            "internal_name" => "C 1",
          },
          "links" => {
            "child_taxons" => [
              grandchild1,
              grandchild2,
            ],
          },
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "child_taxons" => [child1],
          },
        }
      end

      it "parses titles" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.children.map(&:title)).to eq(["Child 1"])
        expect(linked_content_item.children.first.children.map(&:title)).to eq(["Grandchild 1", "Grandchild 2"])
      end

      it "parses internal names" do
        expect(linked_content_item.internal_name).to eq("My lovely taxon")
        expect(linked_content_item.children.map(&:internal_name)).to eq(["C 1"])
        expect(linked_content_item.children.first.children.map(&:internal_name)).to eq(["GC 1", "GC 2"])
      end
    end

    context "when a content item has no descendants" do
      let(:expanded_links) do
        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {},
        }
      end

      it "parses each level of taxons" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.children).to be_empty
      end
    end

    context "when a content item has children but no grandchildren" do
      let(:expanded_links) do
        child1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/child-1",
          "title" => "Child 1",
          "details" => {
            "internal_name" => "C 1",
          },
          "links" => {},
        }

        child2 = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/child-2",
          "title" => "Child 2",
          "details" => {
            "internal_name" => "C 2",
          },
          "links" => {},
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "child_taxons" => [child1, child2],
          },
        }
      end

      it "parses each level of taxons" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.children.map(&:title)).to eq(["Child 1", "Child 2"])
        expect(linked_content_item.children.map(&:children)).to all(be_empty)
      end
    end

    context "when a content item has parents and grandparents" do
      let(:expanded_links) do
        grandparent1 = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandparent-1",
          "title" => "Grandparent 1",
          "details" => {
            "internal_name" => "GP 1",
          },
          "links" => {},
        }

        parent1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-1",
          "title" => "Parent 1",
          "details" => {
            "internal_name" => "P 1",
          },
          "links" => {
            "parent_taxons" => [
              grandparent1,
            ],
          },
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "parent_taxons" => [parent1],
          },
        }
      end

      it "parses the ancestors" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.parent.title).to eq("Parent 1")
        expect(linked_content_item.ancestors.map(&:title)).to eq(["Grandparent 1", "Parent 1"])
      end
    end

    context "when a content item has parents but no grandparents" do
      let(:expanded_links) do
        parent1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-1",
          "title" => "Parent 1",
          "details" => {
            "internal_name" => "P 1",
          },
          "links" => {},
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "parent_taxons" => [parent1],
          },
        }
      end

      it "parses the ancestors" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.parent.title).to eq("Parent 1")
        expect(linked_content_item.ancestors.map(&:title)).to eq(["Parent 1"])
      end
    end

    context "when a content item has no parents" do
      let(:expanded_links) do
        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {},
        }
      end

      it "parses the ancestors" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.parent).to be_nil
        expect(linked_content_item.ancestors.map(&:title)).to be_empty
      end
    end

    context "when a content item has multiple parents" do
      let(:expanded_links) do
        parent1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-1",
          "title" => "Parent 1",
          "details" => {
            "internal_name" => "P 1",
          },
          "links" => {},
        }

        parent2 = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-2",
          "title" => "Parent 2",
          "details" => {
            "internal_name" => "P 2",
          },
          "links" => {},
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "parent_taxons" => [parent1, parent2],
          },
        }
      end

      it "uses only the first parent" do
        expect(linked_content_item.title).to eq("Taxon")
        expect(linked_content_item.parent.title).to eq("Parent 1")
        expect(linked_content_item.ancestors.map(&:title)).to eq(["Parent 1"])
      end
    end

    context "when a content item tagged to multiple taxons" do
      let(:expanded_links) do
        grandparent1 = {
          "content_id" => "22aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandparent-1",
          "title" => "Grandparent 1",
          "details" => {
            "internal_name" => "GP 1",
          },
          "links" => {},
        }

        parent1 = {
          "content_id" => "11aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-1",
          "title" => "Parent 1",
          "details" => {
            "internal_name" => "P 1",
          },
          "links" => {
            "parent_taxons" => [grandparent1],
          },
        }

        taxon1 = {
          "content_id" => "00aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/this-is-a-taxon",
          "title" => "Taxon 1",
          "details" => {
            "internal_name" => "T 1",
          },
          "links" => {
            "parent_taxons" => [parent1],
          },
        }

        grandparent2 = {
          "content_id" => "03aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandparent-2",
          "title" => "Grandparent 2",
          "details" => {
            "internal_name" => "GP 2",
          },
          "links" => {},
        }

        parent2 = {
          "content_id" => "02aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/parent-2",
          "title" => "Parent 2",
          "details" => {
            "internal_name" => "P 2",
          },
          "links" => {
            "parent_taxons" => [grandparent2],
          },
        }

        taxon2 = {
          "content_id" => "01aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/this-is-also-a-taxon",
          "title" => "Taxon 2",
          "details" => {
            "internal_name" => "T 2",
          },
          "links" => {
            "parent_taxons" => [parent2],
          },
        }

        {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "taxons" => [taxon1, taxon2],
          },
        }
      end

      it "parses the taxons and their ancestors" do
        expect(linked_content_item.parent).to be_nil
        expect(linked_content_item.taxons.map(&:title)).to eq(["Taxon 1", "Taxon 2"])
        expect(linked_content_item.taxons_with_ancestors.map(&:title).sort).to eq(
          [
            "Grandparent 1",
            "Grandparent 2",
            "Parent 1",
            "Parent 2",
            "Taxon 1",
            "Taxon 2",
          ],
        )
      end
    end

    context "when there is a homepage content item with a level_one_taxon and a child" do
      it "parses each level of taxons from home page" do
        root_taxon = {
          "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
          "base_path" => "/",
          "title" => "GOV.UK homepage",
          "details" => {},
        }

        child_for_level_one_taxon = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/transport_child",
          "title" => "Transport child",
          "details" => {
            "internal_name" => "TC 1",
          },
          "links" => {},
        }

        level_one_taxon = {
          "content_id" => "a4038b29-b332-4f13-98b1-1c9709e216bc",
          "base_path" => "/transport/all",
          "title" => "Transport",
          "details" => {
            "internal_name" => "Transport",
          },
          "links" => {
            "child_taxons" => [child_for_level_one_taxon],
            "root_taxon" => [root_taxon],
          },
        }

        expanded_links = {
          "expanded_links" => {
            "level_one_taxons" => [level_one_taxon],
          },
        }

        expanded_links2 = {
          "expanded_links" => {
            "child_taxons" => [child_for_level_one_taxon],
          },
        }

        allow(publishing_api).to receive(:get_content).with("f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a").and_return(root_taxon)
        allow(publishing_api).to receive(:get_expanded_links).with("f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a").and_return(expanded_links)
        allow(publishing_api).to receive(:get_expanded_links).with("a4038b29-b332-4f13-98b1-1c9709e216bc").and_return(expanded_links2)

        homepage_taxon = LinkedContentItem.from_content_id(
          content_id: root_taxon["content_id"],
          publishing_api:,
        )

        expect(homepage_taxon.title).to eq("GOV.UK homepage")
        expect(homepage_taxon.parent).to be_nil
        expect(homepage_taxon.children.map(&:title)).to eq(%w[Transport])
        expect(homepage_taxon.descendants.map(&:title)).to eq(["Transport", "Transport child"])
        expect(homepage_taxon.children.first.children.first.title).to eq("Transport child")
      end
    end

    context "when there are minimal responses with missing links and details hashes" do
      it "parses taxons with nil internal names" do
        grandchild1 = {
          "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandchild-1",
          "title" => "Grandchild 1",
        }

        grandchild2 = {
          "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/grandchild-2",
          "title" => "Grandchild 2",
        }

        child1 = {
          "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/child-1",
          "title" => "Child 1",
          "links" => {
            "child_taxons" => [
              grandchild1,
              grandchild2,
            ],
          },
        }

        content_item = {
          "content_id" => "aaaaaa14-9bca-40d9-abb4-4f21f9792a05",
          "base_path" => "/minimal-taxon",
          "title" => "Minimal Taxon",
        }

        expanded_links = {
          "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
          "expanded_links" => {
            "child_taxons" => [child1],
            "parent_taxons" => [
              {
                "content_id" => "ffaadc14-9bca-40d9-abb4-4f21f9792aff",
                "title" => "Parent Taxon",
                "base_path" => "/parent",
              },
            ],
          },
        }

        allow(publishing_api).to receive(:get_content).with("aaaaaa14-9bca-40d9-abb4-4f21f9792a05").and_return(content_item)
        allow(publishing_api).to receive(:get_expanded_links).with("aaaaaa14-9bca-40d9-abb4-4f21f9792a05").and_return(expanded_links)

        minimal_taxon = LinkedContentItem.from_content_id(
          content_id: content_item["content_id"],
          publishing_api:,
        )

        expect(minimal_taxon.title).to eq("Minimal Taxon")
        expect(minimal_taxon.internal_name).to be_nil
        expect(minimal_taxon.parent.title).to eq("Parent Taxon")
        expect(minimal_taxon.parent.internal_name).to be_nil
        expect(minimal_taxon.descendants.map(&:title)).to eq(["Child 1", "Grandchild 1", "Grandchild 2"])
        expect(minimal_taxon.descendants.map(&:internal_name)).to all(be_nil)
      end
    end
  end
end
