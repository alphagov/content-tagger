require 'rails_helper'

RSpec.describe Facets::RemoteFacetGroupsService do
  let(:publishing_api) { Services.publishing_api_with_long_timeout }

  describe "find_all" do
    let(:api_response) { double(:response, to_hash: { "results" => "Woo!" }) }

    before do
      allow(publishing_api).to receive(:get_content_items).and_return(api_response)
    end

    it "fetches all facet groups from the publishing api" do
      result = subject.find_all
      expect(result).to eq("Woo!")
      expect(publishing_api).to have_received(:get_content_items)
        .with(
          document_type: "facet_group",
          order: "-public_updated_at",
          q: "",
          search_in: %i[title],
          page: 1,
          per_page: 50,
          states: %w[published],
        )
    end
  end

  describe "find" do
    let(:api_response) { double(:response, to_hash: "Yeah!") }
    before do
      allow(publishing_api).to receive(:get_expanded_links).and_return(api_response)
    end

    it "fetches the expanded facet group from the publishing api" do
      result = subject.find("abc-123")
      expect(result).to eq("Yeah!")
      expect(publishing_api).to have_received(:get_expanded_links).with("abc-123")
    end
  end
end
