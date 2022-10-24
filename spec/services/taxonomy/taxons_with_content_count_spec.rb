RSpec.describe Taxonomy::TaxonsWithContentCount do
  let(:search_result_fixture) do
    {
      results: [],
      total: 334_263,
      start: 0,
      facets: {
        taxons: {
          options: [
            {
              value: {
                slug: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
              },
              documents: 100,
            },
            {
              value: {
                slug: "720f650a-331f-4575-9c56-376d1eaa9ca0",
              },
              documents: 200,
            },
            {
              value: {
                slug: "a544d48b-1e9e-47fb-b427-7a987c658c14",
              },
              documents: 300,
            },
          ],
        },
      },
    }
  end

  let(:expanded_links_fixture) do
    {
      expanded_links: {
        child_taxons: [
          {
            title: "foo",
            content_id: "720f650a-331f-4575-9c56-376d1eaa9ca0",
            links: {
              child_taxons: [
                {
                  title: "bar",
                  content_id: "a544d48b-1e9e-47fb-b427-7a987c658c14",
                  links: {},
                },
              ],
            },
          },
        ],
      },
    }
  end

  describe "#nested_tree" do
    it "returns a nested tree structure" do
      stub_request(:get, "https://search-api.test.gov.uk/search.json?count=0&debug=include_withdrawn&facet_taxons=1000&filter_part_of_taxonomy_tree=b92079ac-f1d9-44c8-bc78-772d54377ee2")
        .to_return(body: search_result_fixture.to_json)

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/b92079ac-f1d9-44c8-bc78-772d54377ee2")
        .to_return(body: expanded_links_fixture.to_json)

      stub_publishing_api_has_item(
        content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
        title: "title",
      )

      size = described_class.new(
        instance_double(
          Taxon,
          content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
          title: "title",
        ),
      )

      expect(size.nested_tree).to eql(
        name: "title",
        content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
        size: 100,
        children: [
          {
            name: "foo",
            content_id: "720f650a-331f-4575-9c56-376d1eaa9ca0",
            size: 200,
            children: [
              {
                name: "bar",
                content_id: "a544d48b-1e9e-47fb-b427-7a987c658c14",
                size: 300,
                children: [],
              },
            ],
          },
        ],
      )
    end
  end

  describe "#max_size" do
    let(:content_item) do
      instance_double(
        ContentItem,
        content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
        title: "title",
      )
    end

    it "returns the max size of the tree" do
      tree = {
        name: "title",
        content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
        size: 100,
        children: [
          {
            name: "foo",
            content_id: "720f650a-331f-4575-9c56-376d1eaa9ca0",
            size: 200,
            children: [
              {
                name: "bar",
                content_id: "a544d48b-1e9e-47fb-b427-7a987c658c14",
                size: 300,
              },
            ],
          },
        ],
      }

      size = described_class.new(content_item)
      allow(size).to receive(:nested_tree).and_return(tree)

      expect(size.max_size).to eq(300)

      taxonomy_size = Taxonomy::TaxonsWithContentCountPresenter.new(size)
      expect(taxonomy_size.bar_width_percentage(100)).to be(10)
      expect(taxonomy_size.bar_width_percentage(300)).to be(30)
    end

    it "returns the max size of the tree for no children" do
      tree = {
        name: "title",
        content_id: "b92079ac-f1d9-44c8-bc78-772d54377ee2",
        size: 100,
        children: [],
      }

      size = described_class.new(content_item)
      allow(size).to receive(:nested_tree).and_return(tree)

      expect(size.max_size).to eq(100)
    end

    it "returns 0% bar width when max_size is 0" do
      size = described_class.new(content_item)
      allow(size).to receive(:max_size).and_return(0)

      expect(size.max_size).to eq(0)
    end
  end
end
