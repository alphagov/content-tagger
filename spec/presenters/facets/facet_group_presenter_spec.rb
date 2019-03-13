require 'rails_helper'

RSpec.describe Facets::FacetGroupPresenter do
  let(:raw_data) do
    {
      "content_id" => "abc-123",
      "title" => "Facet group 1",
      "details" => { "name" => "Facet group 1", "description" => "This is facet group 1" },
      "publication_state" => "published",
      "expanded_links" => {
        "facets" => [
          {
            "title" => "Facet 1",
            "details" => { "key" => "facet_1" },
            "links" => {
              "facet_values" => [
                {
                  "content_id" => "FACET-VALUE-UUID",
                  "details" => { "label" => "Facet value 1" }
                }
              ]
            }
          }
        ]
      }
    }
  end

  subject(:instance) { described_class.new(raw_data) }

  describe "facet group attributes" do
    it "exposes content_id, title, name, description and state" do
      expect(instance.content_id).to eq(raw_data["content_id"])
      expect(instance.title).to eq(raw_data["title"])
      expect(instance.name).to eq(raw_data["details"]["name"])
      expect(instance.description).to eq(raw_data["details"]["description"])
      expect(instance.state).to eq(raw_data["publication_state"])
    end
  end

  describe "facets" do
    it "presents facets" do
      expect(instance.facets.first).to be_a(Facets::FacetPresenter)
    end
  end

  describe "grouped_facet_values" do
    it "creates a nested facet hash" do
      expect(instance.grouped_facet_values).to eq(
        [["Facet 1", [["Facet value 1", "FACET-VALUE-UUID"]]]]
      )
    end
  end
end
