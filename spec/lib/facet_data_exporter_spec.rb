require "rails_helper"
require "facet_data_exporter"

RSpec.describe FacetDataExporter do
  let(:publishing_api) { Services.publishing_api }
  let(:facet_group) do
    {
      content_id: "abc-123-def-456",
      title: "A facet group",
      description: "Test data facet group",
      facets: [
        {
          content_id: "bcd-234-efg-567",
          title: "A facet",
          key: "a_facet",
          facet_values: [
            {
              content_id: "cde-345-fgh-678",
              title: "A facet value",
              value: "a-facet-value",
            },
            {
              content_id: "def-456-ghi-789",
              title: "Another facet value",
              value: "another-facet-value",
            },
            {
              content_id: "efg-567-hij-890",
              title: "Yet another facet value",
              value: "yet-another-facet-value",
            },
          ],
        },
        {
          content_id: "gbh-123-gef-000",
          title: "Another facet",
          key: "another_facet",
          facet_values: [
            {
              content_id: "dce-435-ghf-888",
              title: "Some facet value",
              value: "some-facet-value",
            },
            {
              content_id: "ddd-444-ggg-777",
              title: "This facet value",
              value: "this-facet-value",
            },
          ],
        },

      ],
    }
  end

  let(:facet) { facet_group[:facets].first }
  let(:content_items) do
    [
      { "content_id" => "zyx-987-cba-654", "base_path" => "/foo", "document_type" => "guide" },
      { "content_id" => "cba-654-zyx-987", "base_path" => "/bar", "document_type" => "doc" },
      { "content_id" => "abc-987-def-654", "base_path" => "/meh", "document_type" => "thing" },
    ]
  end

  let(:links_for_content_ids) do
    {
      "zyx-987-cba-654" => %w[cde-345-fgh-678 def-456-ghi-789 ddd-444-ggg-777 dce-435-ghf-888],
      "cba-654-zyx-987" => %w[cde-345-fgh-678 efg-567-hij-890 dce-435-ghf-888],
      "abc-987-def-654" => %w[def-456-ghi-789],
    }
  end
  let(:linked_items_response) { double(:linked_items, to_hash: content_items) }

  let(:logger) { double(:logger, info: nil) }
  let(:csv) { [] }

  subject(:instance) { described_class.new("abc-123-def-456", "data.csv", "test-facets.yml", logger) }

  before do
    allow(YAML).to receive(:load_file).and_return(facet_group)
    allow(publishing_api).to receive(:get_linked_items)
      .with("abc-123-def-456", fields: %w[content_id base_path document_type], link_type: "facet_groups")
      .and_return(linked_items_response)
    links_for_content_ids.each do |k, v|
      links_response = double(:links_response, to_hash: { "links" => { "facet_values" => v } })
      allow(publishing_api).to receive(:get_links).with(k).and_return(links_response)
    end
    allow(CSV).to receive(:open).with("data.csv", "wb").and_yield(csv)
    allow(csv).to receive(:<<)
  end

  describe "export" do
    before { instance.export }

    it "finds content items linked to a facet group" do
      expect(publishing_api).to have_received(:get_linked_items)
        .with("abc-123-def-456", fields: %w[content_id base_path document_type], link_type: "facet_groups")
    end

    it "finds links for each content item linked to a facet group" do
      links_for_content_ids.each do |content_id, _|
        expect(publishing_api).to have_received(:get_links).with(content_id)
      end
    end

    it "writes tagged content data to csv" do
      expect(csv).to have_received(:<<).with(
        [
          "/foo",
          "a-facet-value,another-facet-value",
          "some-facet-value,this-facet-value",
        ],
      )
      expect(csv).to have_received(:<<).with(
        [
          "/bar",
          "a-facet-value,yet-another-facet-value",
          "some-facet-value",
        ],
      )
      expect(csv).to have_received(:<<).with(
        [
          "/meh",
          "another-facet-value",
          "",
        ],
      )
    end
  end
end
