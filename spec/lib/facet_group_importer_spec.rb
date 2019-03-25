require 'rails_helper'
require 'facet_group_importer'

RSpec.describe FacetGroupImporter do
  let(:publishing_api) { Services.publishing_api_with_long_timeout }
  let(:facet_group) do
    {
      content_id: "abc-123-def-456",
      title: "A facet group",
      description: "Test data facet group",
      facets: [
        {
          combine_mode: "and",
          content_id: "bcd-234-efg-567",
          display_as_result_metadata: true,
          filterable: true,
          key: "a_facet",
          name: "A facet",
          preposition: "do something with",
          type: "content_id",
          filter_key: 'facet_filter_key',
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
          ]
        }
      ]
    }
  end
  let(:facet) { facet_group[:facets].first }
  let(:logger) { double(:logger, info: nil, warn: nil) }

  subject(:instance) { described_class.new("/path/to/test-facets.yml", logger) }

  before { allow(YAML).to receive(:load_file).and_return(facet_group) }

  describe "import" do
    before do
      allow(publishing_api).to receive(:put_content)
      allow(publishing_api).to receive(:patch_links)
      instance.import
    end

    it "reads facet group definitions from file" do
      expect(YAML).to have_received(:load_file).with("/path/to/test-facets.yml")
    end

    it "creates the facet_group content item" do
      expect(publishing_api).to have_received(:put_content)
        .with(
          facet_group[:content_id],
          a_hash_including(
            document_type: "facet_group",
            publishing_app: "content-tagger",
            rendering_app: "finder-frontend",
            schema_name: "facet_group",
            title: "A facet group",
            details: {
              description: "Test data facet group",
              name: "A facet group",
            }
          )
        )
    end

    it "creates the facets content items" do
      expect(publishing_api).to have_received(:put_content)
        .with(
          facet[:content_id],
          a_hash_including(
            document_type: "facet",
            publishing_app: "content-tagger",
            rendering_app: "finder-frontend",
            schema_name: "facet",
            title: "A facet",
            details: {
              combine_mode: "and",
              display_as_result_metadata: true,
              filterable: true,
              key: "a_facet",
              filter_key: 'facet_filter_key',
              name: "A facet",
              preposition: "do something with",
              type: "content_id",
            }
          )
        )
    end

    it "creates the facet_values content items" do
      facet[:facet_values].each do |facet_value|
        expect(publishing_api).to have_received(:put_content)
          .with(
            facet_value[:content_id],
            a_hash_including(
              document_type: "facet_value",
              publishing_app: "content-tagger",
              rendering_app: "finder-frontend",
              schema_name: "facet_value",
              title: facet_value[:title],
              details: {
                label: facet_value[:title],
                value: facet_value[:value],
              }
            )
          )
      end
    end

    it "links the facet_groups to the facets" do
      expect(publishing_api).to have_received(:patch_links)
        .with(
          facet_group[:content_id],
          a_hash_including(
            links: { facets: [facet[:content_id]] }
          )
        )
    end

    it "links the facet_values to the facets" do
      facet[:facet_values].each do |facet_value|
        expect(publishing_api).to have_received(:patch_links)
          .with(
            facet_value[:content_id],
            a_hash_including(
              links: { parent: [facet[:content_id]] }
            )
          )
      end
    end

    it "links the facets to the facet group and facet values" do
      expect(publishing_api).to have_received(:patch_links)
        .with(
          facet[:content_id],
          a_hash_including(
            links: {
              facet_values: facet[:facet_values].map { |v| v[:content_id] },
              parent: [facet_group[:content_id]],
            }
          )
        )
    end
  end

  describe "discard_draft_group" do
    before do
      allow(publishing_api).to receive(:discard_draft)
      allow(publishing_api).to receive(:patch_links)
      instance.discard_draft_group
    end

    it "discards the draft facet group" do
      expect(publishing_api).to have_received(:discard_draft).with(facet_group[:content_id])
    end

    it "discards the draft facets" do
      expect(publishing_api).to have_received(:discard_draft).with(facet[:content_id])
    end

    it "discards the draft facet values" do
      facet[:facet_values].each do |facet_value|
        expect(publishing_api).to have_received(:discard_draft).with(facet_value[:content_id])
      end
    end

    it "patches empty facet group links" do
      expect(publishing_api).to have_received(:patch_links)
        .with(facet_group[:content_id], links: { facets: [] })
    end

    it "patches empty facet links" do
      expect(publishing_api).to have_received(:patch_links)
        .with(facet[:content_id], links: { facet_group: [], facet_values: [] })
    end

    it "patches empty facet value links" do
      expect(publishing_api).to have_received(:patch_links)
        .with(facet_group[:content_id], links: { facets: [] })
    end
  end

  describe "publish_facet_group" do
    before do
      allow(publishing_api).to receive(:publish)
      instance.publish
    end

    it "publishes the draft facet group" do
      expect(publishing_api).to have_received(:publish).with(facet_group[:content_id], "minor")
    end

    it "publishes the draft facets" do
      expect(publishing_api).to have_received(:publish).with(facet[:content_id], "minor")
    end

    it "publishes the draft facet values" do
      facet[:facet_values].each do |facet_value|
        expect(publishing_api).to have_received(:publish).with(facet_value[:content_id], "minor")
      end
    end
  end
end
