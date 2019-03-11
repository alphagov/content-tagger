require "rails_helper"
require "facet_data_tagger"

RSpec.describe FacetDataTagger do
  let(:publishing_api) { Services.publishing_api_with_long_timeout }
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
          ]
        }
      ]
    }
  end

  let(:facet) { facet_group[:facets].first }
  let(:content_ids_for_paths) do
    {
      "/foo" => "zyx-987-cba-654",
      "/bar" => "cba-654-zyx-987",
      "/meh" => "abc-987-def-654",
    }
  end

  let(:logger) { double(:logger, info: nil) }

  subject(:instance) { described_class.new("data.csv", "test-facets.yml", logger) }

  before do
    allow(YAML).to receive(:load_file).and_return(facet_group)
    allow(publishing_api).to receive(:patch_links)
    allow(publishing_api).to receive(:lookup_content_ids).and_return(content_ids_for_paths)
    allow(CSV).to receive(:foreach)
      .and_yield(["/foo", "another-facet-value,yet-another-facet-value"])
      .and_yield(["/bar", "a-facet-value"])
      .and_yield(["/meh", "an-invalid-facet-value,a-facet-value"])
      .and_yield(["/derp", "an-invalid-facet-value"])
  end

  describe "initialize" do
    it "gets content ids matching paths" do
      expect(instance.paths_mapped_to_content_ids).to eq(content_ids_for_paths)
    end

    it "populates facet data" do
      expect(instance.facet_data["/foo"]).to eq(%w[def-456-ghi-789 efg-567-hij-890])
      expect(instance.facet_data["/bar"]).to eq(%w[cde-345-fgh-678])
      expect(instance.facet_data["/meh"]).to eq(%w[cde-345-fgh-678])
      expect(instance.facet_data["/derp"]).to eq([])
    end
  end

  describe "link_content_to_facet_values" do
    before { instance.link_content_to_facet_values }

    it "patches facet_groups links in the Publishing API" do
      expect(publishing_api).to have_received(:patch_links)
        .with("zyx-987-cba-654", links: a_hash_including(facet_groups: %w[abc-123-def-456]))
      expect(publishing_api).to have_received(:patch_links)
        .with("cba-654-zyx-987", links: a_hash_including(facet_groups: %w[abc-123-def-456]))
      expect(publishing_api).to have_received(:patch_links)
        .with("abc-987-def-654", links: a_hash_including(facet_groups: %w[abc-123-def-456]))
    end

    it "patches facet_values links in the Publishing API" do
      expect(publishing_api).to have_received(:patch_links)
        .with("zyx-987-cba-654", links: a_hash_including(facet_values: %w[def-456-ghi-789 efg-567-hij-890]))
      expect(publishing_api).to have_received(:patch_links)
        .with("cba-654-zyx-987", links: a_hash_including(facet_values: %w[cde-345-fgh-678]))
      expect(publishing_api).to have_received(:patch_links)
        .with("abc-987-def-654", links: a_hash_including(facet_values: %w[cde-345-fgh-678]))
    end

    it "only patches links for valid content" do
      expect(publishing_api).to have_received(:patch_links).exactly(3).times
    end
  end
end
